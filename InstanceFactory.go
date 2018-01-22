package instancefactory

import (
	"sync"
)

type InstanceFactory interface {
	GetStructImpl(interfaceName string) interface{}
}

var instance InstanceFactory = nil
var setMutex sync.Mutex

func GetFactory() InstanceFactory {
	return instance
}

func SetFactory(fac InstanceFactory) bool {
	if instance == nil {
		setMutex.Lock()
		if instance == nil {
			instance = fac
			return true
		}
		setMutex.Unlock()
	}

	return false
}
