/* Copyright (C) 2014, 2015 BMW Group
 * Author: Lutz Bichler (lutz.bichler@bmw.de)
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */
package org.genivi.commonapi.someip.generator

import java.util.HashSet
import java.util.List
import javax.inject.Inject
import org.eclipse.core.resources.IResource
import org.eclipse.xtext.generator.IFileSystemAccess
import org.franca.core.franca.FAttribute
import org.franca.core.franca.FBroadcast
import org.franca.core.franca.FInterface
import org.franca.core.franca.FMethod
import org.franca.core.franca.FModelElement
import org.franca.core.franca.FVersion
import org.franca.deploymodel.core.FDeployedProvider
import org.franca.deploymodel.dsl.fDeploy.FDProvider
import org.genivi.commonapi.core.generator.FTypeGenerator
import org.genivi.commonapi.core.generator.FrancaGeneratorExtensions
import org.genivi.commonapi.someip.deployment.PropertyAccessor

import static com.google.common.base.Preconditions.*
import org.genivi.commonapi.someip.preferences.PreferenceConstantsSomeIP

class FInterfaceSomeIPProxyGenerator {
    @Inject private extension FrancaGeneratorExtensions
    @Inject private extension FrancaSomeIPGeneratorExtensions

    def generateProxy(FInterface fInterface, IFileSystemAccess fileSystemAccess,
        PropertyAccessor deploymentAccessor, 
        List<FDProvider> providers, 
        IResource modelid) {
        fileSystemAccess.generateFile(fInterface.someipProxyHeaderPath, PreferenceConstantsSomeIP.P_OUTPUT_PROXIES_SOMEIP,
            fInterface.generateProxyHeader(deploymentAccessor, modelid))
        fileSystemAccess.generateFile(fInterface.someipProxySourcePath, PreferenceConstantsSomeIP.P_OUTPUT_PROXIES_SOMEIP,
            fInterface.generateProxySource(deploymentAccessor, providers, modelid))
    }
    
    def private generateProxyHeader(FInterface _interface, 
                                    PropertyAccessor _accessor,
                                    IResource _modelid) '''
        «generateCommonApiLicenseHeader(_interface, _modelid)»
        «FTypeGenerator::generateComments(_interface, false)»
        #ifndef «_interface.defineName.toUpperCase»_SOMEIP_PROXY_HPP_
        #define «_interface.defineName.toUpperCase»_SOMEIP_PROXY_HPP_

        #include <«_interface.proxyBaseHeaderPath»>
        «IF _interface.base != null»
            #include <«_interface.base.someipProxyHeaderPath»>
        «ENDIF»
        «val DeploymentHeaders = _interface.getDeploymentInputIncludes(_accessor)»
        «DeploymentHeaders.map["#include <" + it + ">"].join("\n")»

        #if !defined (COMMONAPI_INTERNAL_COMPILATION)
        #define COMMONAPI_INTERNAL_COMPILATION
        #endif

        #include <CommonAPI/SomeIP/Factory.hpp>
        #include <CommonAPI/SomeIP/Proxy.hpp>
        #include <CommonAPI/SomeIP/Types.hpp>
        «IF _interface.hasAttributes»
            #include <CommonAPI/SomeIP/Attribute.hpp>
        «ENDIF»
        «IF _interface.hasBroadcasts»
            #include <CommonAPI/SomeIP/Event.hpp>
            «IF _interface.hasSelectiveBroadcasts»
                #include <CommonAPI/Types.hpp>
                #include <CommonAPI/SomeIP/SelectiveEvent.hpp>
            «ENDIF»
        «ENDIF»
        «IF !_interface.managedInterfaces.empty»
            #include <CommonAPI/SomeIP/ProxyManager.hpp>
        «ENDIF»

        #undef COMMONAPI_INTERNAL_COMPILATION

        #include <string>

        «_interface.generateVersionNamespaceBegin»
        «_interface.model.generateNamespaceBeginDeclaration»

        class «_interface.someipProxyClassName»
        	: virtual public «_interface.proxyBaseClassName», 
        	  virtual public «IF _interface.base != null»«_interface.base.getTypeCollectionName(_interface)»SomeIPProxy«ELSE»CommonAPI::SomeIP::Proxy«ENDIF» {
        public:
            «_interface.someipProxyClassName»(
                            const CommonAPI::SomeIP::Address &_address,
                            const std::shared_ptr<CommonAPI::SomeIP::ProxyConnection> &_connection);

            virtual ~«_interface.someipProxyClassName»() { }

            «FOR attribute : _interface.attributes»
            virtual «attribute.generateGetMethodDefinition»;
            «ENDFOR»

            «FOR broadcast : _interface.broadcasts»
            virtual «broadcast.generateGetMethodDefinition»;
            «ENDFOR»

            «FOR method : _interface.methods»
            «FTypeGenerator::generateComments(method, false)»
            virtual «method.generateDefinition(false)»;
            «IF !method.isFireAndForget»
                virtual «method.generateAsyncDefinition(false)»;
            «ENDIF»
            «ENDFOR»

            «FOR managed : _interface.managedInterfaces»
                virtual CommonAPI::ProxyManager &«managed.proxyManagerGetterName»();
            «ENDFOR»

            virtual void getOwnVersion(uint16_t &_major, uint16_t &_minor) const;

         private:
            «FOR attribute : _interface.attributes»
                «attribute.someipClassName(_interface, _accessor)» «attribute.someipClassVariableName»;
            «ENDFOR»

            «FOR broadcast : _interface.broadcasts»
                «broadcast.someipClassName(_interface, _accessor)» «broadcast.someipClassVariableName»;
            «ENDFOR»

            «FOR managed : _interface.managedInterfaces»
                CommonAPI::SomeIP::ProxyManager «managed.proxyManagerMemberName»;
            «ENDFOR»
        };
        
        «_interface.model.generateNamespaceEndDeclaration»
        «_interface.generateVersionNamespaceEnd»

        #endif // «_interface.defineName»_SOMEIP_PROXY_HPP_
    '''

    def private generateProxySource(FInterface _interface, 
                                    PropertyAccessor _accessor,
                                    List<FDProvider> providers,
                                    IResource _modelid) '''
        «generateCommonApiLicenseHeader(_interface, _modelid)»
        «FTypeGenerator::generateComments(_interface, false)»
        #include <«_interface.someipProxyHeaderPath»>
        
        #if !defined (COMMONAPI_INTERNAL_COMPILATION)
        #define COMMONAPI_INTERNAL_COMPILATION
        #endif

        #include <CommonAPI/SomeIP/AddressTranslator.hpp>
        
        #undef COMMONAPI_INTERNAL_COMPILATION

        «_interface.generateVersionNamespaceBegin»
        «_interface.model.generateNamespaceBeginDeclaration»

        std::shared_ptr<CommonAPI::SomeIP::Proxy> create«_interface.someipProxyClassName»(
                            const CommonAPI::SomeIP::Address &_address,
                            const std::shared_ptr<CommonAPI::SomeIP::ProxyConnection> &_connection) {
            return std::make_shared<«_interface.someipProxyClassName»>(_address, _connection);
        }

        INITIALIZER(register«_interface.someipProxyClassName») {
            «FOR p : providers»
                «val PropertyAccessor providerAccessor = new PropertyAccessor(new FDeployedProvider(p))»
                «FOR i : p.instances.filter[target == _interface]»
                    CommonAPI::SomeIP::AddressTranslator::get()->insert(
                        "local:«_interface.fullyQualifiedName»:«providerAccessor.getInstanceId(i)»",
                        0x«Integer.toHexString(_accessor.getSomeIpServiceID(_interface))», 0x«Integer.toHexString(providerAccessor.getSomeIpInstanceID(i))»);
                «ENDFOR»
            «ENDFOR»
            CommonAPI::SomeIP::Factory::get()->registerProxyCreateMethod(
                «_interface.elementName»::getInterface(),
                &create«_interface.someipProxyClassName»);
        }

        «_interface.someipProxyClassName»::«_interface.someipProxyClassName»(
                            const CommonAPI::SomeIP::Address &_address,
                            const std::shared_ptr<CommonAPI::SomeIP::ProxyConnection> &_connection)
              : CommonAPI::SomeIP::Proxy(_address, _connection «_interface.hasInterfaceSelectiveBroadacsts(_accessor)»)«IF _interface.base != null»,«ENDIF»
				«_interface.generateSomeIPBaseInstantiations»
                «FOR attribute : _interface.attributes BEFORE ',' SEPARATOR ','»
                    «attribute.generateVariableInit(_accessor, _interface)»
                «ENDFOR»
                «FOR broadcast : _interface.broadcasts BEFORE ',' SEPARATOR ','»
                    «broadcast.someipClassVariableName»(*this, «broadcast.getEventGroups(_accessor).head», «broadcast.getEventIdentifier(_accessor)», «broadcast.getDeployments(_interface, _accessor)»)
                «ENDFOR»
                «FOR managed : _interface.managedInterfaces BEFORE ',' SEPARATOR ','»
                    «managed.proxyManagerMemberName»(*this, "«managed.fullyQualifiedName»", «getSomeIpServiceIDForInterface(providers, managed)»)
                «ENDFOR»
        {
        }

        «FOR attribute : _interface.attributes»
            «attribute.generateGetMethodDefinitionWithin(_interface.someipProxyClassName)» {
                return «attribute.someipClassVariableName»;
            }
        «ENDFOR»

        «FOR broadcast : _interface.broadcasts»
            «broadcast.generateGetMethodDefinitionWithin(_interface.someipProxyClassName)» {
                return «broadcast.someipClassVariableName»;
            }
        «ENDFOR»

        «FOR method : _interface.methods»
            «val timeout = method.getTimeout(_accessor)»
            «val inParams = method.generateInParams(_accessor)»
            «val outParams = method.generateOutParams(_accessor, false)»
            «FTypeGenerator::generateComments(method, false)»
            «method.generateDefinitionWithin(_interface.someipProxyClassName, false)» {
                «method.generateProxyHelperDeployments(_interface, false, _accessor)»
                «IF method.isFireAndForget»
                    «method.generateProxyHelperClass(_interface, _accessor)»::callMethod(
                «ELSE»
                    «IF timeout != 0»
                        static CommonAPI::CallInfo info(«timeout»);
                    «ENDIF»
                    «method.generateProxyHelperClass(_interface, _accessor)»::callMethodWithReply(
                «ENDIF»
                    *this,
                    «method.getMethodIdentifier(_accessor)»,
                    «method.isReliable(_accessor)»,
                    «IF !method.isFireAndForget»(_info ? _info : «IF timeout != 0»&info«ELSE»&CommonAPI::SomeIP::defaultCallInfo«ENDIF»),«ENDIF»
                    «IF inParams != ""»«inParams»,«ENDIF»
                    _internalCallStatus«IF method.hasError»,
                    deploy_error«ENDIF»«IF outParams != ""»,
                    «outParams»«ENDIF»);
                «method.generateOutParamsValue(_accessor)»
            }
            «IF !method.isFireAndForget»
                «method.generateAsyncDefinitionWithin(_interface.someipProxyClassName, false)» {
                    «IF timeout != 0»
                        static CommonAPI::CallInfo info(«timeout»);
                    «ENDIF»
                    «method.generateProxyHelperDeployments(_interface, true, _accessor)»
                    return «method.generateProxyHelperClass(_interface, _accessor)»::callMethodAsync(
                        *this,
                        «method.getMethodIdentifier(_accessor)»,
                        «method.isReliable(_accessor)»,
                        (_info ? _info : «IF timeout != 0»&info«ELSE»&CommonAPI::SomeIP::defaultCallInfo«ENDIF»),
                        «IF inParams != ""»«inParams»,«ENDIF»
                        «method.generateCallback(_interface, _accessor)»);
                }
            «ENDIF»
        «ENDFOR»
        
        «FOR managed : _interface.managedInterfaces»
            CommonAPI::ProxyManager& «_interface.someipProxyClassName»::«managed.proxyManagerGetterName»() {
                return «managed.proxyManagerMemberName»;
            }
        «ENDFOR»


        void «_interface.someipProxyClassName»::getOwnVersion(uint16_t& ownVersionMajor, uint16_t& ownVersionMinor) const {
            «val FVersion itsVersion = _interface.version»
            «IF itsVersion != null»
                ownVersionMajor = «_interface.version.major»;
                ownVersionMinor = «_interface.version.minor»;
            «ELSE»
                ownVersionMajor = 0;
                ownVersionMinor = 0;
            «ENDIF»
        }

        «_interface.model.generateNamespaceEndDeclaration»
        «_interface.generateVersionNamespaceEnd»
    '''

    def private getSomeIpServiceIDForInterface(List<FDProvider> _providers, FInterface _interface) {
        for (FDProvider p : _providers) {
            for (instance : p.instances) {
                if (instance.target == _interface) {
                    return "0x" + Integer.toHexString(_interface.accessor.getSomeIpServiceID(instance.target))
                }
            }
        }
        return "UNDEFINED_SERVICE_ID"
    }

    def private someipClassVariableName(FModelElement fModelElement) {
        checkArgument(!fModelElement.elementName.nullOrEmpty, 'FModelElement has no name: ' + fModelElement)
        fModelElement.elementName.toFirstLower + '_'
    }

    def private someipClassVariableName(FBroadcast fBroadcast) {
        checkArgument(!fBroadcast.elementName.nullOrEmpty, 'FModelElement has no name: ' + fBroadcast)
        var classVariableName = fBroadcast.elementName.toFirstLower

        if (fBroadcast.selective)
            classVariableName = classVariableName + 'Selective'

        classVariableName = classVariableName + '_'

        return classVariableName
    }
    
    def private generateProxyHelperDeployments(FMethod _method,
                                               FInterface _interface,
                                               boolean _isAsync,
                                               PropertyAccessor _accessor) '''
    «IF _method.hasError»
        CommonAPI::Deployable<«_method.errorType», «_method.getErrorDeploymentType(false)»> deploy_error(«_method.getErrorDeploymentRef(_interface, _accessor)»);
    «ENDIF»
    «FOR a : _method.inArgs»
        CommonAPI::Deployable<«a.getTypeName(_method, true)», «a.getDeploymentType(_interface, true)»> deploy_«a.name»(_«a.name», «a.getDeploymentRef(a.array, _method, _interface, _accessor)»);
    «ENDFOR»
    «FOR a : _method.outArgs»
        CommonAPI::Deployable<«a.getTypeName(_method, true)», «a.getDeploymentType(_interface, true)»> deploy_«a.name»(«a.getDeploymentRef(a.array, _method, _interface, _accessor)»);
    «ENDFOR»
    '''
    
    def private generateProxyHelperClass(FMethod _method, 
                                         FInterface _interface,
                                         PropertyAccessor _accessor) '''
    CommonAPI::SomeIP::ProxyHelper<
        CommonAPI::SomeIP::SerializableArguments<
            «FOR a : _method.inArgs»
                CommonAPI::Deployable<
                    «a.getTypeName(_method, true)», 
                    «a.getDeploymentType(_interface, true)»
                >«IF a != _method.inArgs.last»,«ENDIF»
            «ENDFOR»
        >,
        CommonAPI::SomeIP::SerializableArguments<
            «IF _method.hasError»
            CommonAPI::Deployable<
                «_method.errorType»,
                «_method.getErrorDeploymentType(false)»
            >«IF !_method.outArgs.empty»,«ENDIF»
            «ENDIF»
            «FOR a : _method.outArgs»
                CommonAPI::Deployable<
                    «a.getTypeName(_method, true)», 
                    «a.getDeploymentType(_interface, true)»
                >«IF a != _method.outArgs.last»,«ENDIF»
            «ENDFOR»
        >
    >'''

    def private generateInParams(FMethod _method, 
                                 PropertyAccessor _accessor) {
        var String inParams = ""
        for (a : _method.inArgs) {
            if (inParams != "") inParams += ", "
            inParams += "deploy_" + a.name
        }
        return inParams
    }

    def private generateOutParams(FMethod _method,
                                  PropertyAccessor _accessor,
                                  boolean _instantiate) {
        var String outParams = ""
        for (a : _method.outArgs) {
            if (outParams != "") outParams += ", "
            outParams += "deploy_" + a.name
        }
        return outParams      
    }
    
    def private generateOutParamsValue(FMethod _method,
                                       PropertyAccessor _accessor) {
        var String outParamsValue = ""
        if (_method.hasError) {
        	outParamsValue += "_error = deploy_error.getValue();\n"
        }
        for (a : _method.outArgs) {
            outParamsValue += "_" + a.name + " = deploy_" + a.name + ".getValue();\n"
        }
        return outParamsValue      
    }

    def private generateCallback(FMethod _method,
                                 FInterface _interface,
                                 PropertyAccessor _accessor) {

        var String error = ""                                     
        if (_method.hasError) {
            error = "deploy_error"
        }                    

        var String callback = "[_callback] (" + generateCallbackParameter(_method, _interface, _accessor) + ") {\n"
        callback += "\t_callback(_internalCallStatus"
        if (_method.hasError) callback += ", _deploy_error.getValue()"
        for (a : _method.outArgs) {
            callback += ", _" + a.name
            callback += ".getValue()"
        }
        callback += ");\n"
        callback += "},\n"
        
        var String out = generateOutParams(_method, _accessor, true)
        if (error != "" && out != "") error += ", "  
        callback += "std::make_tuple(" + error + out + ")" 
        return callback
    }

    def private generateCallbackParameter(FMethod _method,
                                          FInterface _interface,
                                          PropertyAccessor _accessor) {
        var String declaration = "CommonAPI::CallStatus _internalCallStatus"
        if (_method.hasError)
            declaration += ", CommonAPI::Deployable<" + _method.errorType + ", " + _method.getErrorDeploymentType(false) + "> _deploy_error"
        for (a : _method.outArgs) {
            declaration += ", "
            declaration += "CommonAPI::Deployable<" + a.getTypeName(_method, true)
                           + ", " + a.getDeploymentType(_interface, true) + "> _" + a.name
        }   
        return declaration                                           
    }

    def private someipClassName(FAttribute _attribute, 
                                FInterface _interface,
                                PropertyAccessor _accessor) {
        var type = "CommonAPI::SomeIP::"

        if (_attribute.isReadonly)
            type = type + "Readonly"

        type = type + "Attribute<" + _attribute.className
        val deployment = _attribute.getDeploymentType(_interface, true)
        if (!deployment.equals("CommonAPI::EmptyDeployment")) type += ", " + deployment
        type += ">"

        if (_attribute.isObservable)
                type = "CommonAPI::SomeIP::ObservableAttribute<" + type + ">"

        return type
    }

    def private generateVariableInit(FAttribute _attribute, 
                                     PropertyAccessor _accessor,
                                     FInterface _interface) {
        var init = _attribute.someipClassVariableName + "(*this"

        if (_attribute.isObservable) {
            init += ", " + _attribute.getNotifierEventGroups(_accessor).head 
                  + ", " + _attribute.getNotifierIdentifier(_accessor)
        }

        if (!_attribute.isReadonly) {
            init += ", " + _attribute.getGetterIdentifier(_accessor) 
                  + ", " + _attribute.isGetterReliable(_accessor) 
                  + ", " + _attribute.getSetterIdentifier(_accessor) 
                  + ", " + _attribute.isSetterReliable(_accessor)
        } else {
            init += ", " + _attribute.getGetterIdentifier(_accessor) 
                  + ", " + _attribute.isGetterReliable(_accessor) 
        }

        val String deployment = _attribute.getDeploymentRef(_attribute.array, null, _interface, _accessor)
        if (deployment != "")
            init += ", " + deployment

        init += ")"

        return init
    }

    def private someipClassName(FBroadcast _broadcast, 
                                FInterface _interface, 
                                PropertyAccessor _accessor) {
        var eventDeclaration = "CommonAPI::SomeIP::"

        if (_broadcast.isSelective)
            eventDeclaration += "Selective"

        eventDeclaration += "Event<" + _broadcast.className 
        for (a : _broadcast.outArgs) {
            eventDeclaration += ", "
            eventDeclaration += a.getDeployable(_interface, _accessor)
        }
        eventDeclaration += '>'

        return eventDeclaration
    }
    
    def private hasInterfaceSelectiveBroadacsts(FInterface _interface, PropertyAccessor _accessor) {
        for (broadcast : _interface.broadcasts) {
            if (broadcast.isSelective) {
                return ", true"
            }
        }
        return ""
    }
}
