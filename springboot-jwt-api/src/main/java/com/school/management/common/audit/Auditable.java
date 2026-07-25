package com.school.management.common.audit;

import java.lang.annotation.ElementType;
import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;
import java.lang.annotation.Target;

/** Marks a service method whose successful execution must be recorded in the audit log. */
@Target(ElementType.METHOD)
@Retention(RetentionPolicy.RUNTIME)
public @interface Auditable {

    /** e.g. CREATE, UPDATE, DELETE */
    String action();

    /** e.g. STUDENT, TEACHER, USER */
    String entity();
}
