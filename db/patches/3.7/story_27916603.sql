alter table domains add feature_allow_anonymous_shopping int default 0;

alter table domains add default_homepage enum('Login','Market Info','Our Sellers','Shop') default 'Login';