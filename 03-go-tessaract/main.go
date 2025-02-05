package main

import (
	"errors"
	"fmt"
	"io"
	"net/http"
	"os"
	"path/filepath"

	"github.com/otiai10/gosseract/v2"
	log "github.com/sirupsen/logrus"
)

func downloadFile(filepath string, url string) error {
	log.Infof("Downloading: %v", url)
	// Get the data
	resp, err := http.Get(url)
	if err != nil {
		return err
	}
	defer resp.Body.Close()

	// Create the file
	out, err := os.Create(filepath)
	if err != nil {
		return err
	}
	defer out.Close()

	// Write the body to file
	_, err = io.Copy(out, resp.Body)
	return err
}

func parseTextFromFile(imageFileName string, tessdata string) (string, error) {
	client := gosseract.NewClient()

	_ = client.SetTessdataPrefix(tessdata)
	_ = client.SetLanguage("eng")
	_ = client.SetPageSegMode(gosseract.PageSegMode(gosseract.PSM_OSD_ONLY))

	defer client.Close()

	_ = client.SetImage(imageFileName)

	text, err := client.Text()
	if err != nil {
		return "", err
	}
	return text, nil
}

func downloadTesseractData() {
	for _, lang := range []string{"eng"} {
		path := filepath.Join(".", fmt.Sprintf("%v.traineddata", lang))
		if _, err := os.Stat(path); errors.Is(err, os.ErrNotExist) {
			_ = downloadFile(path, fmt.Sprintf("https://raw.githubusercontent.com/tesseract-ocr/tessdata/main/%v.traineddata", lang))
		}
	}
}

func main() {
	downloadTesseractData()
	for _, arg := range os.Args[1:] {
		text, _ := parseTextFromFile(arg, ".")
		log.Infof("[%s] %s", filepath.Base(arg), text)
	}
}
