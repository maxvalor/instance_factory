package instancefactoryimpl

// This file is generated by update.sh.

import (
	impl "github.com/maxvalor/instancefactory/sample/sample1/printer/impl"
)

type InstanceFactoryImpl struct {
	implMap map[string]func() interface{}
}

func NewInstanceFactoryImpl() (instance *InstanceFactoryImpl) {
	instance = &InstanceFactoryImpl{}
	instance.implMap = make(map[string]func() interface{})
	instance.implMap["github.com/maxvalor/instancefactory/sample/sample1/printer.Printer"] = getimplPrinterImpl
	return
}

func (fac *InstanceFactoryImpl)GetStructImpl(interfaceName string) (instance interface{}) {
	f := fac.implMap[interfaceName]
	if f != nil {
		instance = f()
	}
	return
}

func getimplPrinterImpl() interface{} {
	return &impl.PrinterImpl{}
}

