package com.springapp.mvc.user;

import org.springframework.data.annotation.Id;

import javax.validation.constraints.NotNull;
import javax.validation.constraints.Size;

public class User {

    @Id
    private String id;

    @Size(min=2, max=30)
    @NotNull
    private String firstName;

    @Size(min=2, max=30)
    @NotNull
    private String lastName;
    private String phone;

    public User(String firstName, String lastName, String phone) {
        this.firstName = firstName;
        this.lastName = lastName;
        this.phone = phone;
    }

    public String getFirstName() {
        return firstName;
    }

    public void setFirstName(String firstName) {
        this.firstName = firstName;
    }

    public String getLastName() {
        return lastName;
    }

    public void setLastName(String lastName) {
        this.lastName = lastName;
    }

    public String getPhone() {
        return phone;
    }

    public void setPhone(String tel) {
        this.phone = phone;
    }

    @Override
    public String toString() {
        return "DataObject [id=" + id + ", firstName=" + firstName + ", lastName=" + lastName + ", phone=" + phone + "]";
    }

}