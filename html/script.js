// Escuchar mensajes del cliente
window.addEventListener('message', function(event) {
    if (event.data.action === 'openMenu') {
        document.querySelector('.container').style.display = 'block';
    }
});

// Función para crear una banda
document.getElementById('createBand').addEventListener('click', () => {
    const bandName = document.getElementById('bandName').value;
    const leader = document.getElementById('leader').value;
    fetch(`https://${GetParentResourceName()}/createBand`, {
        method: 'POST',
        body: JSON.stringify({ bandName, leader }),
        headers: {
            'Content-Type': 'application/json'
        }
    });
});

// Función para añadir miembros
document.getElementById('addMember').addEventListener('click', () => {
    const bandName = document.getElementById('bandName').value;
    const member = document.getElementById('member').value;
    fetch(`https://${GetParentResourceName()}/addMember`, {
        method: 'POST',
        body: JSON.stringify({ bandName, member }),
        headers: {
            'Content-Type': 'application/json'
        }
    });
});

// Función para iniciar una actividad
document.getElementById('startActivity').addEventListener('click', () => {
    const bandName = document.getElementById('bandName').value;
    const activityType = document.getElementById('activityType').value;
    fetch(`https://${GetParentResourceName()}/startActivity`, {
        method: 'POST',
        body: JSON.stringify({ bandName, activityType }),
        headers: {
            'Content-Type': 'application/json'
        }
    });
});

// Cerrar el menú con ESC
document.addEventListener('keydown', (e) => {
    if (e.key === 'Escape') {
        fetch(`https://${GetParentResourceName()}/closeMenu`, {
            method: 'POST'
        });
    }
});