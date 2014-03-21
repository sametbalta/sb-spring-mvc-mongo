package com.springapp.mvc.user;

public class Response {
    private boolean success;
    private String msg;
    private User user;

    public Response(User user, boolean success, String msg) {
        this.user = user;
        this.success = success;
        this.msg = msg;
    }

    @Override
    public String toString() {
        return "DataObject [success=true, msg=" + msg + ", user=" + user.toString() + "]";
    }
}
