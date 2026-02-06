<!DOCTYPE html>
<html lang="pt-br">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <meta content="PJ" name="author" />
  <title>Login | Lock kids</title>
  <link rel="shortcut icon" href="./img/icon.png" />
  <link href="//cdn.jsdelivr.net/npm/bootstrap@5.0.2/dist/css/bootstrap.min.css" rel="stylesheet" />
  <link rel="stylesheet" href="//cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" />
  <link rel="stylesheet" href="//cdn.jsdelivr.net/npm/bootstrap-icons@1.10.5/font/bootstrap-icons.css" />
  <script src="//cdn.jsdelivr.net/npm/jquery@3.6.0/dist/jquery.min.js"></script>
</head>
<body style="background: radial-gradient(circle, rgba(49,56,62,1) 0%, rgba(27,30,38,1) 100%);">
  <section class="min-vh-100 d-flex flex-column justify-content-center align-items-center" style="background-image: url('./img/background.png'); background-size: 190%; background-position: center;">
    <div class="text-center mb-4">
      <img src="./img/logo_1376x509.png" alt="Logo" height="100" />
    </div>

    <div class="card" style="background-color: #00060c; width: 100%; max-width: 400px;">
      <div class="card-body p-4">
        <div class="text-center mb-4">
          <h5 class="fs-4 text-primary">Bem-vindo!</h5>
          <p class="text-muted">Bem-vindo ao painel Lock Kids</p>
        </div>
        <form id="login_form" onsubmit="event.preventDefault();">
          <input type="hidden" name="login" id="login" />
          <div class="mb-3">
            <label for="username" class="form-label text-white">Usuário</label>
            <input name="username" type="text" class="form-control" id="username" placeholder="Coloque o Usuário" />
          </div>
          <div class="mb-3">
            <label for="password-input" class="form-label text-white">Senha</label>
            <input name="password" type="password" class="form-control" id="password-input" placeholder="******" />
          </div>
          <div class="text-center">
            <button type="submit" onclick="enviardados('login_form')" class="btn btn-primary w-100">Entrar</button>
          </div>
        </form>
      </div>
    </div>

    <footer class="text-center mt-5 text-white">
      <div class="d-flex justify-content-center align-items-center">
        <img src="./img/logo_tranparente2.png" alt="Lock Kids" height="40" />
        <span class="ms-2 text-uppercase" style="font-size: 1.25rem;">Lock KIds V 1.0</span>
      </div>
    </footer>
  </section>

  <script src="./js/sweetalert2.js"></script>
  <script>
    var solicitacaoPendente = false;
    function enviardados(id_formulario) {
      if (solicitacaoPendente) {
        SweetAlert2('Aguarde!', 'warning');
        setTimeout(() => solicitacaoPendente = false, 3000);
        return;
      }

      solicitacaoPendente = false;
      var dados = $("#" + id_formulario).serialize();
      $.ajax({
        type: "GET",
        url: "./api/login.php",
        data: dados,
        success: function (response) {
          if (response.trim() === '') {
            SweetAlert2('Resposta do servidor vazia.', 'error');
          } else {
            var jsonResponse = JSON.parse(response);
            if (jsonResponse.icon === 'error') {
              SweetAlert2(jsonResponse.title, jsonResponse.icon);
            } else {
              SweetAlert2(jsonResponse.title, jsonResponse.icon);
              if (jsonResponse.url) {
                setTimeout(() => window.location.href = jsonResponse.url, parseInt(jsonResponse.time, 10));
              }
            }
          }
        },
        error: function () {
          SweetAlert2('Erro na solicitação!', 'error');
        },
        complete: function () {
          solicitacaoPendente = false;
        }
      });
    }

    function SweetAlert2(title, icon) {
      const Toast = Swal.mixin({
        toast: true,
        position: "top-end",
        showConfirmButton: false,
        timer: 2000,
        timerProgressBar: true,
        didOpen: (toast) => {
          toast.onmouseenter = Swal.stopTimer;
          toast.onmouseleave = Swal.resumeTimer;
        }
      });
      Toast.fire({ icon: icon, title: title });
    }
  </script>
</body>
</html>
