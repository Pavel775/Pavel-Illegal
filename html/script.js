// Ocultar el menú al inicio
window.addEventListener('message', function(event) {
    if (event.data.action === 'hideMenu') {
        document.getElementById('mainMenu').style.display = 'none';
        document.getElementById('npcMenu').style.display = 'none';
    } else if (event.data.action === 'openMenu') {
        if (event.data.menuType === 'main') {
            document.getElementById('mainMenu').style.display = 'block';
            document.getElementById('npcMenu').style.display = 'none';
        }
    } else if (event.data.action === 'openNPCMenu') {
        document.getElementById('mainMenu').style.display = 'none';
        document.getElementById('npcMenu').style.display = 'block';

        if (event.data.npcType === 'safe') {
            document.getElementById('npcTitle').textContent = 'Caja Fuerte';
            document.getElementById('safeOptions').style.display = 'block';
            document.getElementById('wardrobeOptions').style.display = 'none';
            document.getElementById('garageOptions').style.display = 'none';
        } else if (event.data.npcType === 'wardrobe') {
            document.getElementById('npcTitle').textContent = 'Armario';
            document.getElementById('safeOptions').style.display = 'none';
            document.getElementById('wardrobeOptions').style.display = 'block';
            document.getElementById('garageOptions').style.display = 'none';
        } else if (event.data.npcType === 'garage') {
            document.getElementById('npcTitle').textContent = 'Garaje';
            document.getElementById('safeOptions').style.display = 'none';
            document.getElementById('wardrobeOptions').style.display = 'none';
            document.getElementById('garageOptions').style.display = 'block';
        }
    }
});

// Función para crear una banda
document.getElementById('createBand').addEventListener('click', () => {
    const bandName = document.getElementById('bandName').value;
    const leader = document.getElementById('leader').value;
    if (bandName && leader) {
        fetch(`https://${GetParentResourceName()}/createBand`, {
            method: 'POST',
            body: JSON.stringify({ bandName, leader }),
            headers: {
                'Content-Type': 'application/json'
            }
        });
    } else {
        alert("Por favor, completa todos los campos.");
    }
});

// Cerrar el menú con ESC
document.addEventListener('keydown', (e) => {
    if (e.key === 'Escape') {
        fetch(`https://${GetParentResourceName()}/closeMenu`, {
            method: 'POST'
        });
    }
});