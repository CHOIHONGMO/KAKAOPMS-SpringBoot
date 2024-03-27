package com.st_ones.common.file.web;

public class FileResult {

    private boolean success;
    private String error;
    private String newUuid;
    private boolean preventRetry;
    private boolean reset;

    public boolean isSuccess() {
        return success;
    }

    public void setSuccess(boolean success) {
        this.success = success;
    }

    public String getError() {
        return error;
    }

    public void setError(String error) {
        this.error = error;
    }

    public String getNewUuid() {
        return newUuid;
    }

    public void setNewUuid(String newUuid) {
        this.newUuid = newUuid;
    }

    public boolean isPreventRetry() {
        return preventRetry;
    }

    public void setPreventRetry(boolean preventRetry) {
        this.preventRetry = preventRetry;
    }

    public boolean isReset() {
        return reset;
    }

    public void setReset(boolean reset) {
        this.reset = reset;
    }
}
