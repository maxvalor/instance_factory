package impl

import (
	"fmt"
	"sync"
)

type PrinterImpl struct {
	
}

var singleton *PrinterImpl
var once sync.Once

func GetInstance() *PrinterImpl {
	once.Do(func() {
		singleton = &PrinterImpl{}
		fmt.Println("New instance of PrintImpl")
	})
	return singleton
}

func (p *PrinterImpl) Print(content string)  {
	fmt.Println(content)
}
