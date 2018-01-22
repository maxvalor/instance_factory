package baseextcontext

import (
	"runtime"
	"strings"
	"path/filepath"
	"path"
)

const seperator = string(filepath.Separator)

func GenerateClassNameByGOPATH(goPath string) (name string) {
	if _, file, _, ok := runtime.Caller(2); ok {
		prefix := path.Join(goPath, "src") + seperator
		if strings.HasPrefix(file, prefix) {
			file = strings.TrimPrefix(file, prefix)
			file = strings.TrimSuffix(file, ".go")
			items := strings.Split(file, seperator)
			for index, str := range items {
				name += str
				switch  {
				case index == len(items) - 2:
					name += "."
				case index == len(items) - 1:
					// do nothing
				default:
					name += seperator
				}
			}
			return
		}
	}

	return
}