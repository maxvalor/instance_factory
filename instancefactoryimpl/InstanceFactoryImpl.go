package instancefactoryimpl

type InstanceFactoryImpl struct {
	implMap map[string]func() interface{}
}

func NewInstanceFactoryImpl() (instance *InstanceFactoryImpl) {
	instance = &InstanceFactoryImpl{}
	instance.implMap = make(map[string]func() interface{})
	return
}

func (fac *InstanceFactoryImpl)GetStructImpl(interfaceName string) (instance interface{}) {
	f := fac.implMap[interfaceName]
	if f != nil {
		instance = f()
	}
	return
}
