window.ST = window.ST || {};

(function(module) {
  
  
  document.addEventListener('fbload', function(){
    console.log(module.accessToken);
    getFriends(getApi);
  })

  function getFriends(callback) {
    if($('.friends-in-common')[0]) {
      var facebookId = $('.friends-in-common')[0].dataset.id;
      callback(facebookId);
    }
    
  }

  function getApi(id) {
    if(id) {
      var url = '/'+id+'/friends';
      console.log(url);
      console.log(module.accessToken);
      console.log(module.appSecretProof)
      FB.api(
        url,
        {
          access_token: module.accessToken,
          appsecret_proof: module.appSecretProof
        },
        function(response) {
            console.log(response);
        }
      );
    }
  }
  
})(window.ST);
