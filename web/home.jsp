<%@page import="entities.Usuario"%>
<%@page import="entities.Municipio"%>
<%@page import="entities.Provincia"%>
<%@page import="entities.Ccaa"%>
<%@page import="entities.Playa"%>
<%@page import="java.util.List"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!doctype html>
<html lang="en">

<head>
  <title>Playas</title>
  <!-- Required meta tags -->
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">

  <!-- Bootstrap CSS -->
  <link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.3.1/css/bootstrap.min.css"
    integrity="sha384-ggOyR0iXCbMQv3Xipma34MD+dH/1fQ784/j6cY/iJTQUOhcWr7x9JvoRxT2MZw1T" crossorigin="anonymous">
  <link rel="stylesheet" href="css/mycss.css">
  <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/font-awesome/4.7.0/css/font-awesome.min.css">
</head>

<body>
<%
    String msg = (String) session.getAttribute("msg");
    List<Ccaa> comunidades = (List<Ccaa>)session.getAttribute("comunidades");
    List<Provincia> provincias = (List<Provincia>)session.getAttribute("provincias");
    List<Municipio> municipios = (List<Municipio>)session.getAttribute("municipios");
    List<Playa> playas = (List<Playa>)session.getAttribute("playas");
    Usuario usuario = (Usuario)session.getAttribute("usuario");
%>
  <div class="container shadow">
    <header>
      <div class="row align-items-center">
        <div class="col-4"><img src="img/logo.png" alt=""></div>
        <div class="col-8">
          <div class="row">
              <div class="ml-auto pr-3">
                <% 
                    if (usuario==null) {%>
                        <button class="btn btn-danger my-2 my-sm-0" data-toggle="modal" data-target="#modallogin">Login</button>    
                    <%} else {%>
                        <span class="text-primary ml-2">Welcome <%=usuario.getNick() %> </span>
                        <a href="Controller?op=logout" class="btn btn-success my-2 my-sm-0">Logout</a>    
                    <%}
                %>
              </div>
          </div>
          <div class="row">
            <div class="col-md-4">
              <form action="Controller?op=vaccaa" method="post">
                <div class="form-group">
                  <label for=""></label>
                  <select class="form-control" name="cbccaa" id="cbccaa" onchange="this.form.submit()">
                    <option disabled selected value="null">Elija CCAA</option>
                    <% for (int i=0;i<comunidades.size();i++) { %>
                    <option value="<%=i %>"><%=comunidades.get(i).getNombre() %></option>
                    <% } %>   
                  </select>
                </div>
              </form>
            </div>
            <div class="col-md-4">
              <form action="Controller?op=vaprovincia" method="post">
                <div class="form-group">
                  <label for=""></label>
                  <select class="form-control" name="cbprovincia" id="cbprovincia" onchange="this.form.submit()">
                    <option disabled selected value="null">Elija Provincia</option>
                    <% 
                        if (provincias!=null){
                            for (Provincia provincia: provincias) {%>
                                <option value="<%=provincia.getId() %>"><%=provincia.getNombre()%></option>
                            <%}
                        }
                    %>  
                  </select>
                </div>
              </form>
            </div>
            <div class="col-md-4">
              <form action="Controller?op=vamunicipio" method="post">
                <div class="form-group">
                  <label for=""></label>
                  <select class="form-control" name="cbmunicipio" id="cbmunicipio" onchange="this.form.submit()">
                    <option disabled selected value="null">Elija Municipio</option>
                        <% 
                        if (municipios!=null){
                            for (Municipio municipio:municipios) { %>
                                <option value="<%=municipio.getId() %>"><%=municipio.getNombre()%></option>
                            <%} 
                        }%> 
                  </select>
                </div>
              </form>
            </div>
          </div>
        </div>
      </div>
    </header>
    <% if(playas!=null) { %>
    <div class="row justify-content-center">
      <% for (Playa miplaya:playas) { %>
      <div class="col-md-6 my-2 d-flex">
        <div class="card text-left d-fill">
          <img src="img/<%=miplaya.getId()%>_<%=miplaya.getImagesList().get(0).getId()%>.jpg" class="img-fluid" alt="...">
          <div class="card-body">
            <h4 class="card-title"><%=miplaya.getNombre() %></h4>
            <p class="card-text"><%=miplaya.getDescripcion() %></p>
          </div>
          <%if (usuario!=null) {%>
          <a data-toggle="modal" data-target="#modalinfo" data-nombreplaya="<%=miplaya.getNombre()%>" data-idplaya="<%=miplaya.getId()%>"><i id="info" class="fa fa-info-circle text-danger fa-3x" aria-hidden="true"></i></a>
          <a href="Controller?op=detail&playa=<%= miplaya.getId()%>"><i id="star" class="fa fa-star-half-o text-warning fa-3x" aria-hidden="true"></i></a>
          <%}%>
        </div>
      </div>
      <%}%>
    </div>
    <% }%>
  </div>

<!-- Modal Login/Register-->
<div class="modal fade" id="modallogin" tabindex="-1" role="dialog" aria-labelledby="exampleModalLabel" aria-hidden="true">
  <div class="modal-dialog" role="document">
    <div class="modal-content">
      <div class="modal-header">
        <h5 class="modal-title" id="exampleModalLabel">Login/Register</h5>
      </div>
      <form action="Controller?op=login" method="POST">
        <div class="modal-body">
              <div class="form-group">
                <label for="exampleInputEmail1">Nick</label>
                <input type="text" class="form-control" name="nick" placeholder="Enter Nick" required="">
              </div>
              <div class="form-group">
                <label for="exampleInputPassword1">Password</label>
                <input type="password" class="form-control" name="pass" placeholder="Enter Paswword" required="">
              </div>
        </div>
        <div class="modal-footer">
          <button type="button" class="btn btn-secondary" data-dismiss="modal">Cancelar</button>
          <button class="btn btn-primary" type="submit">Login/Register</button>
        </div>
      </form>

    </div>
  </div>
</div>

<!-- Modal info -->
<div class="modal fade" id="modalinfo" tabindex="-1" role="dialog" aria-labelledby="modelTitleId" aria-hidden="true">
  <div class="modal-dialog" role="document">
    <div class="modal-content">
      <div class="modal-header">
        <h5 class="modal-title text-center bg-primary w-100 text-white">Calificación de la playa</h5>
      </div>
      <div class="modal-body table-responsive">
          <h4 class="text-primary w-100 text-center">  <!-- se rellena con Ajax --></h4>
          <div>  <!-- se rellena con Ajax --></div>
      </div>
      <div class="modal-footer">
        <button type="button" class="btn btn-primary" data-dismiss="modal">Aceptar</button>
      </div>
    </div>
  </div>
</div>

<div id="tostadaMsg" style="position: absolute;top: 20px;left:50%;transform: translateX(-50%)" data-delay="4000" class="toast bg-danger" role="alert" aria-live="assertive" aria-atomic="true">
    <div class="toast-header">
        <%if (msg!=null) {%>
            <strong class="mr-auto"><%=msg%></strong>
        <%}%>
    </div>
</div>
  <!-- Optional JavaScript -->
  <!-- jQuery first, then Popper.js, then Bootstrap JS -->
  <script src="https://code.jquery.com/jquery-3.3.1.min.js"></script>
  <script src="https://stackpath.bootstrapcdn.com/bootstrap/4.3.1/js/bootstrap.min.js"
    integrity="sha384-JjSmVgyd0p3pXB1rRibZUAYoIIy6OrQ6VrjIEaFf/nJGzIxFDsf4x0xIM+B07jRM"
    crossorigin="anonymous"></script>
  <script src="js/myjs.js"></script>
  <script>$('#cbccaa').val("<%=session.getAttribute("cbccaa") %>");</script>
  <script>$('#cbprovincia').val("<%=session.getAttribute("cbprovincia") %>");</script>
  <script>$('#cbmunicipio').val("<%=session.getAttribute("cbmunicipio") %>");</script>
  <%if (msg!=null) {%>
        <script>
            $('#tostadaMsg').toast('show')
        </script>
        <%
        session.removeAttribute("msg");
    }%>
</body>

</html>