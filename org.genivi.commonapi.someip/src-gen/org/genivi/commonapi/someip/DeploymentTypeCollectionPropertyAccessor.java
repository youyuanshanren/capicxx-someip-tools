/*******************************************************************************
* This file has been generated by Franca's FDeployGenerator.
* Source: deployment spec 'org.genivi.commonapi.someip.deployment'
*******************************************************************************/
package org.genivi.commonapi.someip;

import java.util.List;
import java.util.ArrayList;
import org.eclipse.emf.ecore.EObject;
import org.franca.core.franca.FInterface;
import org.franca.core.franca.FField;
import org.franca.core.franca.FEnumerationType;
import org.franca.deploymodel.core.FDeployedTypeCollection;

/**
 * Accessor for deployment properties for 'org.genivi.commonapi.someip.deployment' specification
 */		
public class DeploymentTypeCollectionPropertyAccessor
	extends org.genivi.commonapi.core.DeploymentTypeCollectionPropertyAccessor
{
	
	private FDeployedTypeCollection target;

	public DeploymentTypeCollectionPropertyAccessor (FDeployedTypeCollection target) {
		super(target);
		this.target = target;
	}
	
	public Integer getSomeIpServiceID (FInterface obj) {
		return target.getInteger(obj, "SomeIpServiceID");
	}
	
	public List<Integer> getSomeIpEventGroups (FInterface obj) {
		return target.getIntegerArray(obj, "SomeIpEventGroups");
	}
	
	public Integer getSomeIpArrayMinLength (EObject obj) {
		return target.getInteger(obj, "SomeIpArrayMinLength");
	}
	
	public Integer getSomeIpArrayMaxLength (EObject obj) {
		return target.getInteger(obj, "SomeIpArrayMaxLength");
	}
	
	public Integer getSomeIpArrayLengthWidth (EObject obj) {
		return target.getInteger(obj, "SomeIpArrayLengthWidth");
	}
	
	public Integer getSomeIpUnionLengthWidth (EObject obj) {
		return target.getInteger(obj, "SomeIpUnionLengthWidth");
	}
	
	public Integer getSomeIpUnionTypeWidth (EObject obj) {
		return target.getInteger(obj, "SomeIpUnionTypeWidth");
	}
	
	public Boolean getSomeIpUnionDefaultOrder (EObject obj) {
		return target.getBoolean(obj, "SomeIpUnionDefaultOrder");
	}
	
	public Integer getSomeIpUnionMaxLength (EObject obj) {
		return target.getInteger(obj, "SomeIpUnionMaxLength");
	}
	
	public Integer getSomeIpStructLengthWidth (EObject obj) {
		return target.getInteger(obj, "SomeIpStructLengthWidth");
	}
	
	public Integer getSomeIpEnumWidth (FEnumerationType obj) {
		return target.getInteger(obj, "SomeIpEnumWidth");
	}
	
	public Integer getSomeIpStringLength (EObject obj) {
		return target.getInteger(obj, "SomeIpStringLength");
	}
	
	public Integer getSomeIpStringLengthWidth (EObject obj) {
		return target.getInteger(obj, "SomeIpStringLengthWidth");
	}
	
	public enum SomeIpStringEncoding {
		utf8, utf16le, utf16be
	}
	public SomeIpStringEncoding getSomeIpStringEncoding (EObject obj) {
		String e = target.getEnum(obj, "SomeIpStringEncoding");
		if (e==null) return null;
		return convertSomeIpStringEncoding(e);
	}
	private SomeIpStringEncoding convertSomeIpStringEncoding (String val) {
		if (val.equals("utf8"))
			return SomeIpStringEncoding.utf8; else 
		if (val.equals("utf16le"))
			return SomeIpStringEncoding.utf16le; else 
		if (val.equals("utf16be"))
			return SomeIpStringEncoding.utf16be;
		return null;
	}
	
	public Integer getSomeIpStructArrayMinLength (FField obj) {
		return target.getInteger(obj, "SomeIpStructArrayMinLength");
	}
	
	public Integer getSomeIpStructArrayMaxLength (FField obj) {
		return target.getInteger(obj, "SomeIpStructArrayMaxLength");
	}
	
	public Integer getSomeIpStructArrayLengthWidth (FField obj) {
		return target.getInteger(obj, "SomeIpStructArrayLengthWidth");
	}
	
	public Integer getSomeIpStructUnionLengthWidth (FField obj) {
		return target.getInteger(obj, "SomeIpStructUnionLengthWidth");
	}
	
	public Integer getSomeIpStructUnionTypeWidth (FField obj) {
		return target.getInteger(obj, "SomeIpStructUnionTypeWidth");
	}
	
	public Boolean getSomeIpStructUnionDefaultOrder (FField obj) {
		return target.getBoolean(obj, "SomeIpStructUnionDefaultOrder");
	}
	
	public Integer getSomeIpStructUnionMaxLength (FField obj) {
		return target.getInteger(obj, "SomeIpStructUnionMaxLength");
	}
	
	public Integer getSomeIpStructStructLengthWidth (FField obj) {
		return target.getInteger(obj, "SomeIpStructStructLengthWidth");
	}
	
	public Integer getSomeIpStructEnumWidth (FField obj) {
		return target.getInteger(obj, "SomeIpStructEnumWidth");
	}
	
	public Integer getSomeIpUnionArrayMinLength (EObject obj) {
		return target.getInteger(obj, "SomeIpUnionArrayMinLength");
	}
	
	public Integer getSomeIpUnionArrayMaxLength (EObject obj) {
		return target.getInteger(obj, "SomeIpUnionArrayMaxLength");
	}
	
	public Integer getSomeIpUnionArrayLengthWidth (EObject obj) {
		return target.getInteger(obj, "SomeIpUnionArrayLengthWidth");
	}
	
	public Integer getSomeIpUnionUnionLengthWidth (EObject obj) {
		return target.getInteger(obj, "SomeIpUnionUnionLengthWidth");
	}
	
	public Integer getSomeIpUnionUnionTypeWidth (EObject obj) {
		return target.getInteger(obj, "SomeIpUnionUnionTypeWidth");
	}
	
	public Boolean getSomeIpUnionUnionDefaultOrder (EObject obj) {
		return target.getBoolean(obj, "SomeIpUnionUnionDefaultOrder");
	}
	
	public Integer getSomeIpUnionUnionMaxLength (EObject obj) {
		return target.getInteger(obj, "SomeIpUnionUnionMaxLength");
	}
	
	public Integer getSomeIpUnionStructLengthWidth (EObject obj) {
		return target.getInteger(obj, "SomeIpUnionStructLengthWidth");
	}
	
	public Integer getSomeIpUnionEnumWidth (EObject obj) {
		return target.getInteger(obj, "SomeIpUnionEnumWidth");
	}
	
	
}
