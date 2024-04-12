package client

import (
	"context"
	"encoding/json"
	"fmt"
	"io"
	"io/ioutil"
	"net/http"
	"strings"

)

type Decode func([]byte, interface{}) error
type HttpClient struct {
	client  *http.Client
	header  map[string]string
	decoder map[string]Decode
}

type HttpClientOption func(*HttpClient)
type HttRequestOption func(*http.Request)

func NewHttpClient(options ...HttpClientOption) *HttpClient {
	hc := &HttpClient{
		client: &http.Client{},
		header: make(map[string]string),
		decoder: map[string]Decode{
			"application/json": json.Unmarshal,
		},
	}
	for _, op := range options {
		op(hc)
	}
	return hc
}

func WithHeader(k, v string) HttpClientOption {
	return func(c *HttpClient) {
		c.header[k] = v
	}
}
func (hc *HttpClient) newRequest(ctx context.Context, method string, u string, body io.Reader, options ...HttRequestOption) (*http.Request, error) {
	req, err := http.NewRequestWithContext(ctx, method, u, body)
	if err != nil {
		return nil, errors.Wrap(err)
	}
	for k, v := range hc.header {
		req.Header.Add(k, v)
	}
	for _, option := range options {
		option(req)
	}
	return req, nil
}

func (hc *HttpClient) sendRequest(req *http.Request) ([]byte, *http.Response, error) {
	resp, err := hc.client.Do(req)
	if err != nil {
		return nil, resp, errors.Wrap(err)
	}
	defer resp.Body.Close()
	body, err := ioutil.ReadAll(resp.Body)
	if err != nil {
		return nil, resp, errors.Wrap(err)
	}
	return body, resp, nil
}
func (hc *HttpClient) Get(ctx context.Context, u string, options ...HttRequestOption) ([]byte, error) {
	req, err := hc.newRequest(ctx, http.MethodGet, u, nil, options...)
	if err != nil {
		return nil, errors.Wrap(err)
	}
	rawData, _, err := hc.sendRequest(req)
	return rawData, err
}

func (hc *HttpClient) Post(ctx context.Context, u string, data io.Reader, options ...HttRequestOption) ([]byte, *http.Response, error) {
	req, err := hc.newRequest(ctx, http.MethodPost, u, data, options...)
	if err != nil {
		return nil, nil, errors.Wrap(err)
	}
	return hc.sendRequest(req)
}
func (hc *HttpClient) getDecoder(contentType string) (Decode, error) {
	if strings.Contains(contentType, ";") {
		parts := strings.Split(contentType, ";")
		if len(parts) > 1 {
			contentType = parts[0]
		}
	}
	if decodeFunc, ok := hc.decoder[contentType]; ok {
		return decodeFunc, nil
	}
	return nil, fmt.Errorf("no decoder found for content-type:%s", contentType)
}

func (hc *HttpClient) GetDecoded(ctx context.Context, u string, ret interface{}, options ...HttRequestOption) error {
	req, err := hc.newRequest(ctx, http.MethodGet, u, nil, options...)
	if err != nil {
		return errors.Wrap(err)
	}
	rawData, resp, err := hc.sendRequest(req)
	if err != nil {
		return errors.Wrap(err)
	}
	contentType := resp.Header.Get("Content-Type")
	decodeFunc, err := hc.getDecoder(contentType)
	if err != nil {
		return errors.Wrap(err)
	}
	if err := decodeFunc(rawData, ret); err != nil {
		return errors.Wrap(err)
	}
	return nil
}

func (hc *HttpClient) PostDecoded(ctx context.Context, u string, data io.Reader, ret interface{}, options ...HttRequestOption) error {
	req, err := hc.newRequest(ctx, http.MethodPost, u, data, options...)
	if err != nil {
		return errors.Wrap(err)
	}
	rawData, resp, err := hc.sendRequest(req)
	if err != nil {
		return errors.Wrap(err)
	}
	contentType := resp.Header.Get("Content-Type")
	decodeFunc, err := hc.getDecoder(contentType)
	if err != nil {
		return errors.Wrap(err)
	}
	if err := decodeFunc(rawData, ret); err != nil {
		return errors.Wrap(err)
	}
	return nil
}
