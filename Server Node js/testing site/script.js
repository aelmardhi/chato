const host = 'https://dardasha.herokuapp.com';

let token 
let usernameInput;
let passwordInput;
let avatar;
let messagesDisplay;
let sendArea;
let notification;
document.addEventListener('DOMContentLoaded', () => {
usernameInput = document.getElementById('username');
passwordInput = document.getElementById('password');
avatar = document.getElementById('avatar');
messagesDisplay = document.getElementById('messages');
sendArea = document.getElementById('sendArea');
sendTo = document.getElementById('sendTo');
notification = document.getElementById('notification');
    
})
let messages =[];
let users = {};
let myApi = axios.create({
    baseURL: 'http://localhost:3000/api',
    timeout:1000,
     headers:{
            'Content-Type':'application/json',
            'auth-token': token
        }
});
var config;

function login(){
    axios.post(host+'/api/user/login', {
        username : usernameInput.value,
        password : passwordInput.value
    } )
    .then(res => {token = res.data['auth-token'];
                 myApi = axios.create({
    baseURL: host+'/api',
    timeout:10000,
     headers:{
            'Content-Type':'application/json',
            'auth-token': token
        }
    
});
                  console.log(res.data.profileImage)
    avatar.setAttribute('src',res.data.profileImage);
               setInterval(getMessage,1000);  
                 })
    .catch(err => console.log(err));
    
} ;

function getUsername(id){
    if (users[id]){
        return users[id];
    }
    
}

function getMessage(){
    console.log(token);
    myApi.get('/messages/text')
    .then(res => {
        if(res.data._id){
           if (messages.find(d => d===res.data.ref||d ===res.data._id )||res.data.ref!=='none')
            {
                
            }else{
              const ele = document.createElement('div');
                ele.classList.add('in');
        ele.innerHTML = `<h2>${res.data.from}\t<span>
${new Date(res.data.date).toDateString()}
</span></h2>
        <p>${res.data.text}</p><br>`;
        messagesDisplay.appendChild(ele); 
                messages.push(res.data._id)
            }
        myApi.post('/messages/delete/text',{
            _id: res.data._id
        }).then(res => console.log(res))
        .catch(err => console.log(err));
        }
        
    })
    .catch(err => {
        if (err.response.data){
            notification.innerHTML = err.response.data
        }
        });
} ;

function send() {
    myApi.post('messages/send/'+sendTo.value+'/text',{
        text : sendArea.value,
        ref : 'none'
    }).then(res => {
        const ele = document.createElement('div');
                ele.classList.add('out');
        ele.innerHTML = `<h2>${res.data.from}\t<span>
${new Date(res.data.date).toDateString()}
</span></h2>
        <p>${res.data.text}</p><br>`;
        messagesDisplay.appendChild(ele); 
                messages.push(res.data._id);
        sendArea.value='';
    })
    .catch(err => {console.log(err.response)
                  if(err.response.data.status !== 200){
            notification.innerHTML = err.response.data
        }
                  });
    
}

