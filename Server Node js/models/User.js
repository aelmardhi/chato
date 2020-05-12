const mongoose = require('mongoose');
let model;
const userSchema = new mongoose.Schema({
    name: {
        type: String,
        required: true,
        min: 4,
        max: 255
    },
    username: {
        type: String,
        required: true,
        max: 255,
        min: 4
    },
    about: {
        type: String,
        required: false,
        default: 'hi,wanna chat?',
        max: 4094,
        min: 4
    },
    password: {
        type: String,
        required: true,
        min: 6,
        max: 1024
    },
    profileImage: {
       type:String ,
        default: 'none'
    },
    lastseen: {
        type: Date,
        default: Date.now
    }
});

try {
    model = mongoose.model('User');
}catch(err) {
    model = mongoose.model('User', userSchema);
}

const updateDate = function(user) {
    user.lastseen = Date.now();
    try {
        return  user.save();
    }catch(err){
        
    }
    return  user;
}

module.exports.User = model;
module.exports.updateDate = updateDate;