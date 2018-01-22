#!/bin/bash

# configure
CURRENT_WORKSPACE=`pwd`
DEFAULT_PACKAGE_NAME="instancefactoryimpl"
DEFAULT_GO_FILE_NAME="InstanceFactoryImpl.go"
EXT_CONTEXT_PACKAGE="extcontext"
EXT_CONTEXT_FILE_NAME="Context.go"
DEFAULT_GO_FILE="${CURRENT_WORKSPACE}/${DEFAULT_PACKAGE_NAME}/${DEFAULT_GO_FILE_NAME}"
DEFAULT_SETTING_FILE="${CURRENT_WORKSPACE}/setting"

PACKAGE_NAME=${DEFAULT_PACKAGE_NAME}
SETTING_FILE=${DEFAULT_SETTING_FILE}
GO_FILE=${DEFAULT_GO_FILE}

function strLeftByDot()
{
    str=$1
    echo ${str%.*}
}

function strLeftBySlash()
{
    str=$1
    echo ${str%/*}
}


function strRightByDot()
{
    str=$1
    echo ${str##*.}
}

function strRightBySlash()
{
    str=$1
    echo ${str##*/}
}

function parsePackage()
{
    importDomain="import ("

    for key in ${!keyImplPkgValuePkgAliasMap[@]}
    do
        pkgAlias=`strRightBySlash ${keyImplPkgValuePkgAliasMap[${key}]}`
        importDomain="${importDomain}\n\t${pkgAlias} \"${key}\""
    done
    importDomain=${importDomain}"\n)"
}

function parseSetting()
{
    declare count=0
    for field in `cat ${SETTING_FILE}`
    do
        let count+=1
        if [ "${count}" == "1" ]; then
            intfItem=${field}
        fi
        if [ "${count}" == "3" ]; then
            implPkg=`strLeftByDot ${field}`
            sttName=`strRightByDot ${field}`

            keyIntfValueImplPkgMap[${intfItem}]=${implPkg}
            keyIntfValueSttNameMap[${intfItem}]=${sttName}
        fi
        if [ "$count" == "5" ]; then
            keyIntfValueNewInstanceFuncMap[${intfItem}]=${field}
        fi
        if [ "$count" == "5" ]; then
            let count=0
        fi
    done
}

function isPackageNameExisted()
{
    implPkgToCheck=$1
    declare count=0
    for key in ${!keyImplPkgValuePkgAliasMap[@]}
    do
        if [ "${key}" == "${implPkgToCheck}" ]; then
            echo "true"
            return
        fi
    done
    echo "false"
}

function isPackageAliasExisted()
{
    pkgAliasToCheck=$1
    declare count=0
    for key in ${!keyImplPkgValuePkgAliasMap[@]}
    do
        pkgAlias="${keyImplPkgValuePkgAliasMap[${key}]}"
        if [ "${pkgAlias}" == "${pkgAliasToCheck}" ]; then
            echo "true"
            return
        fi
    done
    echo "false"
}

function aliasImplPackage()
{
    implPkg=$1
    pkgAlias=`strRightBySlash ${implPkg}`

    declare existed
    if [ "${pkgAlias}" == "${PACKAGE_NAME}" ]; then
        existed="true"
    else
        existed=`isPackageAliasExisted ${pkgAlias}`
    fi
    while [ "${existed}" == "true" ]
    do
        let aliasCount+=1
        pkgAlias="${pkgAlias}${aliasCount}"
        existed=`isPackageAliasExisted ${pkgAlias}`
    done

    keyImplPkgValuePkgAliasMap[${implPkg}]=${pkgAlias}
}

function definePackageAlias()
{
    for key in ${!keyIntfValueImplPkgMap[@]}
    do
        implPkg=${keyIntfValueImplPkgMap[${key}]}
        existed=`isPackageNameExisted ${implPkg}`
        if [ "${existed}" == "false" ]; then
            aliasImplPackage ${implPkg}
        fi
    done

    # synchronize package alias
    for key in ${!keyIntfValueImplPkgMap[@]}
    do
        implPkg=${keyIntfValueImplPkgMap[${key}]}
        for implPkgKey in ${!keyImplPkgValuePkgAliasMap[@]}
        do
            if [ "${implPkg}" == "${implPkgKey}" ]; then
                keyIntfValuePkgAliasMap[${key}]="${keyImplPkgValuePkgAliasMap[${implPkgKey}]}"
            fi
        done
    done
}

function parseNewFactoryMethod()
{
    newFactoryMethod="func NewInstanceFactoryImpl() (instance *InstanceFactoryImpl) {\n\tinstance = &InstanceFactoryImpl{}\n\tinstance.implMap = make(map[string]func() interface{})\n"
    for key in ${!keyIntfValueSttNameMap[@]}
    do
        newFactoryMethod=${newFactoryMethod}"\tinstance.implMap[\"${key}\"] = get${keyIntfValuePkgAliasMap[${key}]}${keyIntfValueSttNameMap[${key}]}\n"
    done
    newFactoryMethod=${newFactoryMethod}"\treturn\n}"
}

function isMethodExisted()
{
    for key in ${GetMethodList}
    do
        if [ "${key}" == "$1" ]; then
            echo "true"
            return 0
        fi
    done
    echo "false"
}

function parseGetMethods()
{
    declare GetMethodList
    for key in ${!keyIntfValueSttNameMap[@]}
    do
        GetMethod=""
        if [ "${keyIntfValueNewInstanceFuncMap[${key}]}" == "_" ]; then
            GetMethod="get${keyIntfValuePkgAliasMap[${key}]}${keyIntfValueSttNameMap[${key}]}"
            existed=`isMethodExisted ${GetMethod}`
            if [ "${existed}" == "false" ]; then
                GetMethodList="${GetMethodList} ${GetMethod}"
                getImplMethods=${getImplMethods}"func get${keyIntfValuePkgAliasMap[${key}]}${keyIntfValueSttNameMap[${key}]}() interface{} {\n\treturn &${keyIntfValuePkgAliasMap[${key}]}.${keyIntfValueSttNameMap[${key}]}{}\n}\n\n"
            fi
        else
            GetMethod="get${keyIntfValuePkgAliasMap[${key}]}${keyIntfValueSttNameMap[${key}]}"
            existed=`isMethodExisted ${GetMethod}`
            if [ "${existed}" == "false" ]; then
                GetMethodList="${GetMethodList} ${GetMethod}"
                getImplMethods=${getImplMethods}"func get${keyIntfValuePkgAliasMap[${key}]}${keyIntfValueSttNameMap[${key}]}() interface{} {\n\treturn ${keyIntfValuePkgAliasMap[${key}]}.${keyIntfValueNewInstanceFuncMap[${key}]}()\n}\n\n"
            fi
        fi
    done
}

function main()
{
    if [ "$1" != "" ]; then
        SETTING_FILE=$1
    fi

    echo ${SETTING_FILE}

    # remove old file
    settingPath=`strLeftBySlash ${SETTING_FILE}`
    goFilePath="${settingPath}/${PACKAGE_NAME}"
    if [ ! -d ${goFilePath} ]; then
        mkdir ${goFilePath}
    fi
    GO_FILE="${goFilePath}/${DEFAULT_GO_FILE_NAME}"
    rm -f ${GO_FILE}

    declare -A keyIntfValueImplPkgMap=()
    declare -A keyIntfValueSttNameMap=()
    declare -A keyIntfValuePkgAliasMap=()
    declare -A keyIntfValueNewInstanceFuncMap=()
    declare -A keyImplPkgValuePkgAliasMap=()
    declare aliasCount=0

    # call process functions
    parseSetting
    definePackageAlias

    # declare content variables
    declare packageName
    declare comment
    declare importDomain
    declare structDefine
    declare newFactoryMethod
    declare getStructImplMethod
    declare getImplMethods

    # parse package
    packageName="package instancefactoryimpl"

    # parse importDomain
    parsePackage

    # parse comment
    comment="// This file is generated by update.sh."

    # parse structDefine
    structDefine="type InstanceFactoryImpl struct {\n\timplMap map[string]func() interface{}\n}"

    # parse getStructImplMethod
    getStructImplMethod="func (fac *InstanceFactoryImpl)GetStructImpl(interfaceName string) (instance interface{}) {\n\tf := fac.implMap[interfaceName]\n\tif f != nil {\n\t\tinstance = f()\n\t}\n\treturn\n}"

    # parse newFactoryMethod
    parseNewFactoryMethod

    # parse getImplMethods
    parseGetMethods

    # write into go file
    echo "${packageName}">>${GO_FILE}
    echo -e "\n${comment}">>${GO_FILE}
    echo -e "\n${importDomain}">>${GO_FILE}
    echo -e "\n${structDefine}">>${GO_FILE}
    echo -e "\n${newFactoryMethod}">>${GO_FILE}
    echo -e "\n${getStructImplMethod}">>${GO_FILE}
    echo -e "\n${getImplMethods}">>${GO_FILE}


    # ext context file
    extContextPath="${settingPath}/${EXT_CONTEXT_PACKAGE}"
    if [ ! -d ${extContextPath} ]; then
        mkdir ${extContextPath}
    fi
    EXT_CONTEXT_FILE="${extContextPath}/${EXT_CONTEXT_FILE_NAME}"
    rm -f ${EXT_CONTEXT_FILE}

    packageName="package extcontext"
    importDomain="import \"github.com/maxvalor/instancefactory/baseextcontext\""
    constDomain="const BuildGOPATH = \"${GOPATH}\""
    getMethod="func GetClassName() (name string) {\n\treturn baseextcontext.GenerateClassNameByGOPATH(BuildGOPATH)\n}"

    echo "${packageName}">> ${EXT_CONTEXT_FILE}
    echo -e "\n${comment}" >> ${EXT_CONTEXT_FILE}
    echo -e "\n${importDomain}" >> ${EXT_CONTEXT_FILE}
    echo -e "\n${constDomain}" >> ${EXT_CONTEXT_FILE}
    echo -e "\n${getMethod}" >> ${EXT_CONTEXT_FILE}
}

main $1