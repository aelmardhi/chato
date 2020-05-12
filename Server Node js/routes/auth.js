const router = require('express').Router();
const {User,updateDate} = require('../models/User');
const Message = require('../models/Message');
const jwt = require('jsonwebtoken');
const verify = require('./verifyToken');
const bcrypt= require('bcryptjs');
const multer = require('multer');
const cloudinary = require('cloudinary');
const cloudinaryStorage = require('multer-storage-cloudinary');
const {rigisterValidation, loginValidation, userUpdateValidation} = require('../validation');



//const storage = multer.diskStorage({
//   destination: function(req,file,cb){
//       cb(null,'uploads/profile_images' );
//    } ,
//    filename: function (req,file,cb){
//        cb(null,req.user._id+file.originalname.substring(file.originalname.lastIndexOf('.')));
//    }
//});
const storage = cloudinaryStorage({
  cloudinary: cloudinary,
  folder: 'profile_images',
  allowedFormats: ['jpg', 'png'],
    transformation: function (req, file, cb) {
    let t = [
      {width: 800, height: 800, crop: "crop"}
    ];
    cb(undefined, t);
  },
  filename: function (req, file, cb) {
    cb(undefined, req.user._id);
  }
});
const fileFilter = (req,file,cb) => {
    if (file.mimetype === 'image/jpeg' || file.mimetype === 'image/png'){
        cb(null,true);
    }else{
        cb(new Error('filetype should be jpeg or png'),false);
    }
};

const upload = multer({
    storage:storage , 
    limits:{
        fileSize: 1024*1024*5
        },
    fileFilter: fileFilter              
                      });
                       
router.post('/ee', (req, res) => {
    res.send(req.params);
})
router.post('/register', async (req,res) => {
    
    const {error} = rigisterValidation(req.body);
    if(error) return res.status(400).send(error.details[0].message);
    
    const usernameExist = await User.findOne({username: req.body.username});
    if (usernameExist) return res.status(400).send('not available username');
    
    const salt = await bcrypt.genSalt(10);
    const hashedPassword = await bcrypt.hash(req.body.password, salt)
    
    const user = new User({
        name: req.body.name,
        username: req.body.username.toLocaleLowerCase(),
        about:req.body.about,
        password: hashedPassword
    });
    
    try{
        const savedUser = await user.save();
        const token = jwt.sign({_id: savedUser._id}, process.env.TOKEN_SECRET);
        res.header('auth-token', token).json({
        'auth-token':token,
        _id: savedUser._id,
        name: savedUser.name,
        username: savedUser.username,
        about: savedUser.about,
        lastseen: savedUser.lastseen,
        profileImage : savedUser.profileImage,
        __v : savedUser.__v
                                         });
    }catch(err){
        res.status(400).send(err);
    }
});

router.post('/login', async (req,res) => {
    
    const {error} = loginValidation(req.body);
    if(error) return res.status(400).send(error.details[0].message);
    
    let user = await User.findOne({username: req.body.username.toLowerCase()});
    if (!user) return res.status(400).send('username is not valid');
    
    const salt = await bcrypt.genSalt(10);
    const validPassword = await bcrypt.compare(req.body.password, user.password)
    if(!validPassword)return res.status(400).send('password is not valid');
    
    const token = jwt.sign({_id: user._id}, process.env.TOKEN_SECRET);
     await updateDate(user);
    res.header('auth-token', token).json({
        'auth-token':token,
        _id: user._id,
        name: user.name,
        username: user.username,
        about: user.about,
        lastseen: user.lastseen,
        profileImage : user.profileImage,
        __v : user.__v
                                         });
//    res.send(user);
})

router.get('/:username', verify,async (req,res) => {
    let user = await User.findOne({username: req.params.username.toLowerCase()});
    if (!user) return res.status(400).send('username is not valid');
    res.json({
        _id: user._id,
        name: user.name,
        username: user.username,
        about: user.about,
        lastseen: user.lastseen,
        profileImage : user.profileImage,
        __v : user.__v
    });
});
router.post('/update',verify,upload.single('profileImage'),async (req,res) => {
//    console.log(req.file);
   const {error} = userUpdateValidation(req.body);
    if(error) return res.status(400).send(error.details[0].message); 
    
    let user = await User.findById(req.user._id);
    if (!user) return res.status(400).send('username is not valid');
    
    if (req.body.name){
        user.name = req.body.name;
    }
    if (req.body.about){
        user.about = req.body.about;
    }
    try{
    if(req.file && req.file.secure_url){
        user.profileImage = req.file.secure_url;
    }}catch(err){
    
    }
    try{
        user.__v = user.__v+1;
        await updateDate(user);
        const savedUser = await user.save();
        res.json({
        _id: user._id,
        name: user.name,
        username: user.username,
        about: user.about,
        lastseen: user.lastseen,
        profileImage : user.profileImage,
        __v : user.__v
    });
    }catch(err){
        res.status(400).send(err);
    }
})

router.get('/', (req,res) => {
    res.send('you are on site');
})

module.exports = router;