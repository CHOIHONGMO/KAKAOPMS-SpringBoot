package com.st_ones.common;

import org.apache.commons.io.FileExistsException;
import org.apache.commons.io.FileUtils;

import java.io.File;
import java.io.IOException;
import java.util.Iterator;
import java.util.List;

/**
 * Created by azure on 2015-06-09.
 */
public class FileProcessor {

    public static void main(String[] args) throws IOException {

        final String IF_FILE_PATH = "C:\\ST-OnesIDE\\workspace\\wiselog";
        final String JOB_DONE_FILE_PATH = "C:\\ST-OnesIDE\\workspace\\wiselog\\jobDoneFiles";
        String[] fileExtensions = {"txt"};

        File directory = new File(IF_FILE_PATH);
        Iterator<File> fileIterator = FileUtils.iterateFiles(directory, fileExtensions, false);
        while(fileIterator.hasNext()) {

            File f = fileIterator.next();
            List<String> stringList = FileUtils.readLines(f, "UTF-8");

            File targetDirectory = new File(JOB_DONE_FILE_PATH);
            try {
                FileUtils.moveFileToDirectory(f, targetDirectory, true);
            } catch(FileExistsException fee) {
                FileUtils.moveFile(f, targetDirectory);
            }
        }
    }
}
