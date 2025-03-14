console.log("Bienvenue dans mon application Django!");

function getCookie(name) {
    let cookieValue = null;
    if (document.cookie && document.cookie !== '') {
        const cookies = document.cookie.split(';');
        for (let i = 0; i < cookies.length; i++) {
            const cookie = cookies[i].trim();
            // Vérifiez si ce cookie commence par le nom que nous recherchons
            if (cookie.substring(0, name.length + 1) === (name + '=')) {
                cookieValue = decodeURIComponent(cookie.substring(name.length + 1));
                break;
            }
        }
    }
    return cookieValue;
}

// Après avoir obtenu le token FCM
fetch('/register-fcm-token/', {
    method: 'POST',
    headers: {
        'Content-Type': 'application/json',
        'X-CSRFToken': getCookie('csrftoken')  // Assurez-vous d'inclure le token CSRF
    },
    body: JSON.stringify({ token: currentToken })
})
.then(response => response.json())
.then(data => {
    console.log(data);
});