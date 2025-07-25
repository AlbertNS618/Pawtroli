package logger

import (
	"fmt"
	"log"
	"os"
)

var (
	InfoLogger    *log.Logger
	ErrorLogger   *log.Logger
	WarningLogger *log.Logger
	DebugLogger   *log.Logger
)

// LogLevel represents different log levels
type LogLevel int

const (
	DEBUG LogLevel = iota
	INFO
	WARNING
	ERROR
)

// InitLogger initializes the logging system with console output only
func InitLogger() error {
	// Initialize loggers with different prefixes and flags
	InfoLogger = log.New(os.Stdout, "[INFO] ", log.Ldate|log.Ltime|log.Lshortfile)
	ErrorLogger = log.New(os.Stderr, "[ERROR] ", log.Ldate|log.Ltime|log.Lshortfile)
	WarningLogger = log.New(os.Stdout, "[WARNING] ", log.Ldate|log.Ltime|log.Lshortfile)
	DebugLogger = log.New(os.Stdout, "[DEBUG] ", log.Ldate|log.Ltime|log.Lshortfile)

	InfoLogger.Println("Logger initialized successfully")
	return nil
}

// LogInfo logs info level messages
func LogInfo(v ...interface{}) {
	if InfoLogger != nil {
		InfoLogger.Println(v...)
	}
}

// LogInfof logs formatted info level messages
func LogInfof(format string, v ...interface{}) {
	if InfoLogger != nil {
		InfoLogger.Printf(format, v...)
	}
}

// LogError logs error level messages
func LogError(v ...interface{}) {
	if ErrorLogger != nil {
		ErrorLogger.Println(v...)
	}
}

// LogErrorf logs formatted error level messages
func LogErrorf(format string, v ...interface{}) {
	if ErrorLogger != nil {
		ErrorLogger.Printf(format, v...)
	}
}

// LogWarning logs warning level messages
func LogWarning(v ...interface{}) {
	if WarningLogger != nil {
		WarningLogger.Println(v...)
	}
}

// LogWarningf logs formatted warning level messages
func LogWarningf(format string, v ...interface{}) {
	if WarningLogger != nil {
		WarningLogger.Printf(format, v...)
	}
}

// LogDebug logs debug level messages
func LogDebug(v ...interface{}) {
	if DebugLogger != nil {
		DebugLogger.Println(v...)
	}
}

// LogDebugf logs formatted debug level messages
func LogDebugf(format string, v ...interface{}) {
	if DebugLogger != nil {
		DebugLogger.Printf(format, v...)
	}
}

// LogHTTPRequest logs HTTP request details
func LogHTTPRequest(method, path, remoteAddr string, statusCode int, duration fmt.Stringer) {
	LogInfof("HTTP %s %s from %s - Status: %d - Duration: %v",
		method, path, remoteAddr, statusCode, duration)
}

// LogFirestoreOperation logs Firestore operation details
func LogFirestoreOperation(operation, collection, docID string, success bool, duration fmt.Stringer) {
	if success {
		LogInfof("Firestore %s operation on %s/%s successful - Duration: %v",
			operation, collection, docID, duration)
	} else {
		LogErrorf("Firestore %s operation on %s/%s failed - Duration: %v",
			operation, collection, docID, duration)
	}
}

// LogAuthOperation logs authentication operation details
func LogAuthOperation(operation, uid string, success bool) {
	if success {
		LogInfof("Auth %s operation successful for UID: %s", operation, uid)
	} else {
		LogWarningf("Auth %s operation failed for UID: %s", operation, uid)
	}
}

// CloseLogger is now a no-op function since there are no files to close
func CloseLogger() {
	// No operation needed
}

// RotateLogFile is now a no-op function since there are no log files
func RotateLogFile() error {
	return nil
}
