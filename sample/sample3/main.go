package main

//go:generate ${GOPATH}/src/github.com/maxvalor/instancefactory/update.sh ${GOPATH}/src/github.com/maxvalor/instancefactory/sample/sample3/setting

import (
	"github.com/maxvalor/instancefactory"
	"github.com/maxvalor/instancefactory/sample/sample3/instancefactoryimpl"
	"github.com/maxvalor/instancefactory/sample/sample3/printera"
)

func main()  {
	instancefactory.SetFactory(instancefactoryimpl.NewInstanceFactoryImpl())
	pt := instancefactory.GetFactory().GetStructImpl(printera.Class).(printera.PrinterA)
	pt.Print("Hello instance factory")
}
