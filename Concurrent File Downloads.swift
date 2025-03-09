//
//  Concurrent File Downloads.swift
//  
//
//  Created by Apple on 09/03/25.
//

import Foundation

// Function to download a file from a given URL
func downloadFile(from url: URL) async throws -> Data {
    let (data, _) = try await URLSession.shared.data(from: url)
    return data
}

// Function to download multiple files concurrently
func downloadMultipleFiles(urls: [URL]) async {
    await withTaskGroup(of: (URL, Data?).self) { taskGroup in
        for url in urls {
            taskGroup.addTask {
                do {
                    let data = try await downloadFile(from: url)
                    return (url, data)
                } catch {
                    print("Failed to download file from \(url): \(error)")
                    return (url, nil)
                }
            }
        }

        for await result in taskGroup {
            let (url, data) = result
            if let data = data {
                print("Successfully downloaded file from \(url), size: \(data.count) bytes")
            } else {
                print("Failed to download file from \(url)")
            }
        }
    }
}

Task {
    let urls = [
        URL(string: "https://example.com/file1")!,
        URL(string: "https://example.com/file2")!,
        URL(string: "https://example.com/file3")!
    ]
    
    await downloadMultipleFiles(urls: urls)
}
