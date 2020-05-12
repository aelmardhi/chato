const router = require('express').Router();
const {User,updateDate} = require('../models/User');
const Message = require('../models/Message');
const verify = require('./verifyToken');
const {textMessageValidation} = require('../validation');


router.post('/send/:username/text', verify,async (req,res) => {
    
    const {error} = textMessageValidation(req.body);
    if(error) return res.status(400).send(error.details[0].message);
    
      const fromUser = await User.findById(req.user._id);
        
    if (!fromUser) return res.status(400).send('login'); 
    const toUser = await User.findOne({username: req.params.username.toLowerCase()});
    if (!toUser) return res.status(400).send('no such user to send to');  
   
    
    
    const message = new Message(toUser.username)({
        from: fromUser.username,
        text: req.body.text,
        ref: req.body.ref
    });
    let savedMessage
    try{
        updateDate(fromUser);
         savedMessage = await message.save();
        
        
       
    }catch(err){
        res.status(400).send(err);
    }
    if (req.body.ref ==='none'|| !req.body.ref || !(req.body.text === 'sent' ||req.body.text === 'delevered' ||req.body.text === 'seen' )){
        const sent = new Message(fromUser.username)({
        from: toUser.username,
        text: "sent",
        ref: savedMessage._id
    });
        try{
            await sent.save();
        }catch(err){
            res.status(400).send(err);
        }
         
    }
    res.send(savedMessage);
})

router.get('/text', verify,async (req,res) => {
    
    const fromUser = await User.findById(req.user._id);
    if (!fromUser) return res.status(400).send('login');
    
    let msg;
    
    try{
        updateDate(fromUser);
        msg = await Message(fromUser.username).findOne();
        
        if(!msg)return res.send("no messages");
    }catch(err){
        return res.status(400).send(err+'jjj');
    }
    if((msg.ref==='none')|| !(msg.text === 'sent' ||msg.text === 'delevered' ||msg.text === 'seen' )){
        const delivered = new Message(msg.from)({
        from: msg.from,
        text: "delevered",
        ref: msg._id
    });
        try{
            await delivered.save();
        }catch(err){
            return res.status(400).send(err+'kkk');
        } 
    }
    res.send(msg);
})

router.post('/delete/text', verify,async (req,res) => {
    const fromUser = await User.findById(req.user._id);
    if (!fromUser) return res.status(400).send('login');
    
    
    
    try{
        updateDate(fromUser);
        const msg = await Message(fromUser.username).findByIdAndDelete(req.body._id);
        res.send(msg);
    }catch(err){
        res.status(40).send(err);
    }
})


module.exports = router;