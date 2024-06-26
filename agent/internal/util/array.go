package util

import "reflect"

//InArray 判断是否在数组中
func InArray(needle interface{}, haystack interface{}) (exists bool) {
	exists = false

	switch reflect.TypeOf(haystack).Kind() {
	case reflect.Slice:
		s := reflect.ValueOf(haystack)

		for i := 0; i < s.Len(); i++ {
			if reflect.DeepEqual(needle, s.Index(i).Interface()) {
				exists = true
				return exists
			}
		}
	}

	return exists
}
