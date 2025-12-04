// Escuchar mensajes del cliente
window.addEventListener('message', function(event) {
    if (event.data.action === 'openMenu') {
        document.querySelector('.container').style.display = 'block';
    }
});

// Funciones para interactuar con el servidor
document.getElementById('createBand').addEventListener('click', () => {
    const bandName = prompt("Nombre de la banda:");
    const leader = prompt("Líder de la banda:");
    fetch(`https://${GetParentResourceName()}/createBand`, {
        method: 'POST',
        body: JSON.stringify({ bandName, leader })
    });
});
