const mongoose = require('mongoose');

const userMessages = function(id){
    messageSchema = new mongoose.Schema({
    from: {
        type: String,
        required: true,
        min: 4,
        max: 255
    },
    text: {
        type: String,
        required: true,
        max: 1024*64,
    },
    ref: {
        type: String,
        required: false,
        default:'none',
        min: 4,
        max: 255
    },
    date: {
        type: Date,
        default: Date.now
    }
});
    try{
        let model = mongoose.model('Msg-'+id);
        return model;
    }catch(err){
        return   mongoose.model('Msg-'+id, messageSchema);
    }
    
} 

module.exports = userMessages;