package util

import (
	"fmt"
	"strings"
	"time"
)

func TryParseBeiJingTime(ts string,
	layouts []string) (time.Time, error) {
	secondsEastOfUTC := int((8 * time.Hour).Seconds())
	beijing := time.FixedZone("Beijing Time", secondsEastOfUTC)
	for _, l := range layouts {
		tParsed, err := time.ParseInLocation(l, ts, beijing)
		if err == nil {
			return tParsed, nil
		}
	}
	return time.Now(), fmt.Errorf("do not find layout for time string:%s, support layouts are:%s", ts, strings.Join(layouts, ","))
}

func TryParseUtcTime(ts string,
	layouts []string) (time.Time, error) {
	for _, l := range layouts {
		tParsed, err := time.Parse(l, ts)
		if err == nil {
			return tParsed, nil
		}
	}
	return time.Now(), fmt.Errorf("do not find layout for time string:%s, support layouts are:%s", ts, strings.Join(layouts, ","))
}
