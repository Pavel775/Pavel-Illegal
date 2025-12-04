// Escuchar mensajes del cliente
window.addEventListener('message', function(event) {
    if (event.data.action === 'openMenu') {
        document.getElementById('mainMenu').style.display = 'block';
        document.getElementById('npcMenu').style.display = 'none';
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

// Función para depositar dinero
document.getElementById('depositMoney').addEventListener('click', () => {
    const bandName = document.getElementById('bandName').value;
    const amount = parseInt(document.getElementById('amount').value);
    fetch(`https://${GetParentResourceName()}/depositMoney`, {
        method: 'POST',
        body: JSON.stringify({ bandName, amount }),
        headers: {
            'Content-Type': 'application/json'
        }
    });
});

// Función para retirar dinero
document.getElementById('withdrawMoney').addEventListener('click', () => {
    const bandName = document.getElementById('bandName').value;
    const amount = parseInt(document.getElementById('amount').value);
    fetch(`https://${GetParentResourceName()}/withdrawMoney`, {
        method: 'POST',
        body: JSON.stringify({ bandName, amount }),
        headers: {
            'Content-Type': 'application/json'
        }
    });
});

// Función para guardar outfit
document.getElementById('saveOutfit').addEventListener('click', () => {
    const bandName = document.getElementById('bandName').value;
    const outfitName = document.getElementById('outfitName').value;
    fetch(`https://${GetParentResourceName()}/saveOutfit`, {
        method: 'POST',
        body: JSON.stringify({ bandName, outfitName }),
        headers: {
            'Content-Type': 'application/json'
        }
    });
});

// Función para cargar outfit
document.getElementById('loadOutfit').addEventListener('click', () => {
    const bandName = document.getElementById('bandName').value;
    const outfitName = document.getElementById('outfitName').value;
    fetch(`https://${GetParentResourceName()}/loadOutfit`, {
        method: 'POST',
        body: JSON.stringify({ bandName, outfitName }),
        headers: {
            'Content-Type': 'application/json'
        }
    });
});

// Función para guardar vehículo
document.getElementById('saveVehicle').addEventListener('click', () => {
    const bandName = document.getElementById('bandName').value;
    fetch(`https://${GetParentResourceName()}/saveVehicle`, {
        method: 'POST',
        body: JSON.stringify({ bandName }),
        headers: {
            'Content-Type': 'application/json'
        }
    });
});

// Función para sacar vehículo
document.getElementById('spawnVehicle').addEventListener('click', () => {
    const bandName = document.getElementById('bandName').value;
    const plate = document.getElementById('vehiclePlate').value;
    fetch(`https://${GetParentResourceName()}/spawnVehicle`, {
        method: 'POST',
        body: JSON.stringify({ bandName, plate }),
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