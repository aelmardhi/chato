const joi = require('@hapi/joi');

const rigisterValidation = data => {
    const schema = joi.object({
    name: joi.string().min(4).required(),
    username: joi.string().min(4).required(),
    about: joi.string().min(4),
    password: joi.string().min(6).required()
});
    return schema.validate(data);
};


const loginValidation = (data) => {
    const schema = joi.object({
    username: joi.string().alphanum().min(4).required(),
    password: joi.string().min(6).required()
});
    return schema.validate(data);
};

const textMessageValidation = (data) => {
    const schema = joi.object({
    text: joi.string().required(),
    ref:  joi.string()
});
    return schema.validate(data);
};

const userUpdateValidation = (data) => {
    const schema = joi.object({
    name: joi.string(),
    about:  joi.string()
});
    return schema.validate(data);
};

module.exports.rigisterValidation = rigisterValidation;
module.exports.loginValidation = loginValidation;
module.exports.textMessageValidation = textMessageValidation;
module.exports.userUpdateValidation = userUpdateValidation;
