let playerId = null;
let BillerId = null;
let amount = 0;

$('#submit-btn').on('click', function () {
    playerId = $('#player-id').val();
    amount = parseFloat($('#amount').val());

    if (playerId && amount > 0) {
        $('#billing-container').addClass('fade-out');
        setTimeout(() => {
            $('#billing-container').removeClass('active fade-out').hide();
            // $('#payment-container').fadeIn().addClass('active');
            closeUI();
        }, 600);

        $.post('https://Daniel-Billing/openPaymentContainer', JSON.stringify({
            playerId: playerId,
            amount: amount,
            BillerId: BillerId
        }));
    } else {
        //alert("Please enter a valid player ID and amount.");
    }
});

$('#close-btn').on('click', function () {
    closeUI()
});

window.addEventListener('message', function (event) {
    if (event.data.type === "toggle") {
        const status = event.data.status;
        const container = document.getElementById('billing-container');
        if (status) {
            container.style.display = 'block';
        } else {
            container.style.display = 'none';
        }
    }

    if (event.data.type === "openPaymentContainer") {
        BillerId = event.data.BillerId;
        playerId = event.data.playerId;
        amount = parseFloat(event.data.amount);

        if (playerId && amount > 0) {
            document.getElementById('billing-container').style.display = 'none';
            document.getElementById('player-info').textContent = `Player ID: ${playerId} | Amount: $${amount}`;
            document.getElementById('payment-container').style.display = 'block';
        } else {
            console.error("Invalid playerId or amount received:", playerId, amount);
        }
    }
});

function closeUI() {
    document.getElementById('payment-container').style.display = 'none';
    document.getElementById('billing-container').style.display = 'none';
    $.post('https://Daniel-Billing/closeUI', JSON.stringify({}));
}

function closeBillingUI() {
    $.post('https://Daniel-Billing/closeUIPayments', JSON.stringify({}));
}

document.getElementById('pay-cash').addEventListener('click', function () {
    sendPaymentRequest('cash');
});

document.getElementById('pay-bank').addEventListener('click', function () {
    sendPaymentRequest('bank');
});

document.addEventListener('keydown', function (event) {
    if (event.key === 'Escape') {
        $('#billing-container').addClass('fade-out');
        setTimeout(() => {
            $('#billing-container').removeClass('active fade-out').hide();
            closeUI();
        }, 600);
    }
});

function sendPaymentRequest(method) {
    if (playerId && amount > 0) {
        $.post('https://Daniel-Billing/PayBill', JSON.stringify({
            playerId: playerId,
            amount: amount,
            method: method,
            BillerId: BillerId
        }), function (response) {
            //console.log("Payment successful:", method, playerId, amount, BillerId);
            closeUI();
        });
    } else {
        alert("Invalid player ID or amount. Please try again.");
    }
}
