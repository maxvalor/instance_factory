# 1. What can the instance factory do?
a) It helps decoupling of call and implementation, completely separate invoking interfaces and implementation classes(struct)

b) It helps managing the generation of objects.

c) When you are facing with the problem: struct A and struct B are in the package a and b.
   You want to call B.m() in the A.n() and call A.na() in B.ma() at the same time. The instance factory can help you.

# 2. Usage
a) Create the setting file in your project directory, add your settings into it.
b) "cd" to the directory of instancefactory, execute the "update.sh" with the parameter that is the path of the setting file.

e.g.:
(in your build.sh:)
...
cd $GOPATH/src/github.com/maxvalor/instancefactory
chmod +x update.sh
./update.sh ${SETTING_FILE}
cd -
...

You can also use this package by go generate. Copy the instancefactoryimpl package into your project firstly. Then follow the example.

e.g.:
(in your main.go)

//go:generate ${GOPATH}/src/github.com/maxvalor/instancefactory/update.sh ${GOPATH}/src/[project]/setting

then run the command to build your project:
...
go generate
go build
...

For detail, refer to the sample.

# 3. Attention!
If you do not want the unused struct to be compiled into the binary file, make sure it is not in the same package in which
the used struct is.

# 4. What will be updated?
The update.sh will be written by golang in the future, so that we can use it any where supporting golang.

