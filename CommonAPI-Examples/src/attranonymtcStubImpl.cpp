/*
* This file was generated by the CommonAPI Generators.
* Used org.genivi.commonapi.core 2.1.6.qualifier.
* Used org.franca.core 0.8.10.201309262002.
*
* This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
* If a copy of the MPL was not distributed with this file, You can obtain one at
* http://mozilla.org/MPL/2.0/.
*/
#include "attranonymtcStubImpl.hpp"
#include <iostream>

attranonymtcStubImpl::attranonymtcStubImpl() {
	setXAttribute(0);
}

attranonymtcStubImpl::~attranonymtcStubImpl() {

}

void attranonymtcStubImpl::incAttribute() {
    int32_t a = getXAttribute() + 1;
    setXAttribute(a);
    std::cout <<  "New attribute value = " << a << "!" << std::endl;
}
