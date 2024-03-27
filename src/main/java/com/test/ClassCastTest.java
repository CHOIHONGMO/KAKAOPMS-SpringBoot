package com.test;

public class ClassCastTest {

    public static void main(String[] args) {

        Child1 c1 = new Child1();
        Parent parent = new Parent();
        c1 = (Child1)parent;

        System.err.println(c1);
    }
}
