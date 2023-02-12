/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package controller;

import entities.Ccaa;
import entities.Municipio;
import entities.Playa;
import entities.Provincia;
import entities.Punto;
import entities.PuntoView;
import entities.Usuario;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;
import java.util.stream.Stream;
import javax.persistence.EntityManager;
import javax.persistence.EntityTransaction;
import javax.persistence.Query;
import javax.servlet.RequestDispatcher;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import util.JPAUtil;

@WebServlet("/Controller")
public class Controller extends HttpServlet {

    private static final long serialVersionUID = 1L;

    /**
     * @see HttpServlet#HttpServlet()
     */
    public Controller() {
        super();
        // TODO Auto-generated constructor stub
    }

    /**
     * @see HttpServlet#doGet(HttpServletRequest request, HttpServletResponse
     * response)
     */
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        String op = request.getParameter("op");
        RequestDispatcher dispatcher;

        Query q;
        List<Playa> playas = null;
        List<Ccaa> comunidades;
        List<Municipio> municipios = null;
        List<Provincia> provincias = null;
        Usuario usuario = null;
        Ccaa comunidadSelected = null;
        Provincia provinciaSelected = null;
        Municipio municipioSelected = null;
        Playa playa= null;

        int searchState=0;

        EntityManager em = JPAUtil.getEntityManagerFactory().createEntityManager(); //Entite Manager-----------------------

        if (op.equals("inicio")) {
            q = em.createNamedQuery("Ccaa.findAll");
            comunidades = (List<Ccaa>) q.getResultList();

            session.setAttribute("playas", playas);
            session.setAttribute("comunidades", comunidades);
            session.setAttribute("municipios", municipios);
            session.setAttribute("provincias", provincias);
            
            dispatcher = request.getRequestDispatcher("home.jsp");
            dispatcher.forward(request, response);

        } else if (op.equals("vaccaa")) {
            // posicion, índice del List
            String cbccaa = request.getParameter("cbccaa");
            comunidades = (List<Ccaa>)session.getAttribute("comunidades");
            comunidadSelected = comunidades.get(Integer.parseInt(cbccaa));
            provincias = comunidadSelected.getProvinciaList();
            
            session.setAttribute("cbccaa", cbccaa);
            session.setAttribute("provincias", provincias);
            
            session.removeAttribute("cbprovincia");
            session.removeAttribute("cbmunicipio");
            session.removeAttribute("municipios");
            session.removeAttribute("playas");

            dispatcher = request.getRequestDispatcher("home.jsp");
            dispatcher.forward(request, response); 

        } else if (op.equals("vaprovincia")) {
            // ahora viene el id de la provincia
            String cbprovincia = request.getParameter("cbprovincia");
            // Lo buscamos en el List de provincias que tenemos en la sesión
            provincias = (List<Provincia>)session.getAttribute("provincias");
            for (Provincia miprovincia:provincias) {
                if (miprovincia.getId() == Short.valueOf(cbprovincia))
                    provinciaSelected = miprovincia;
            }
            municipios = provinciaSelected.getMunicipioList();
            
            session.setAttribute("cbprovincia", cbprovincia);
            session.setAttribute("municipios", municipios);
            
            session.removeAttribute("cbmunicipio");
            session.removeAttribute("playas");

            dispatcher = request.getRequestDispatcher("home.jsp");
            dispatcher.forward(request, response);
        } else if (op.equals("vamunicipio")) {
            // De nuevo viene el id del municipio    
            String cbmunicipio = request.getParameter("cbmunicipio");
            // Lo bucamos en la BDs a traves de su id (clave)
            municipioSelected = em.find(Municipio.class , Integer.parseInt(cbmunicipio));
            playas = municipioSelected.getPlayaList();
            
            session.setAttribute("cbmunicipio", cbmunicipio);
            session.setAttribute("playas", playas);

            dispatcher = request.getRequestDispatcher("home.jsp");
            dispatcher.forward(request, response);
        } else if (op.equals("login")) {
            String nick = request.getParameter("nick");
            String pass = request.getParameter("pass");

            q = em.createQuery("SELECT u FROM Usuario u WHERE u.nick = '"+nick+"' AND u.pass = '"+pass+"'");
            usuario = (Usuario) q.getSingleResult();

            if (usuario==null) { // Login incorrecto procedemos a insertarlo
                usuario = new Usuario(Short.MIN_VALUE);
                usuario.setNick(nick);
                usuario.setPass(pass);
                EntityTransaction t = em.getTransaction();
                t.begin();
                em.persist(usuario);
                t.commit();
            }
            session.setAttribute("usuario", usuario);
            
            dispatcher = request.getRequestDispatcher("home.jsp");
            dispatcher.forward(request, response);
        } else if (op.equals("logout")) {
            session.removeAttribute("usuario");
            
            dispatcher = request.getRequestDispatcher("home.jsp");
            dispatcher.forward(request, response);  
        } else if (op.equals("detail")){
            // Nos vine el id de la playa
            String idplaya = request.getParameter("playa");
            //Lo buscamos en el List de playas que tenemos en la sesión
            //a través de un filtro. No funciona filtro. Arreglar
            //List<Playa> playanew = playas.stream()                        
            //    .filter(p -> p.getId() == Integer.parseInt(idplaya))
            //    .collect(Collectors.toList());
            playas = (List<Playa>) session.getAttribute("playas");
            playa = em.find(Playa.class, Integer.parseInt(idplaya));
            // Objetenemos la media de puntos de la playa
            // aprovechando que están los puntos que de han dado 
            // a la playa, dentro del objeto playa
            List<Punto> puntos = playa.getPuntoList();
            float puntosTotal = 0;
         
            for (Punto punto: puntos){
                puntosTotal = punto.getPuntos() + puntosTotal;
            }
            Integer star = Math.round(puntosTotal / puntos.size());
            
            session.setAttribute("playa", playa);
            session.setAttribute("star", star);

            dispatcher = request.getRequestDispatcher("detail.jsp");
            dispatcher.forward(request, response);
        } else if (op.equals("puntuacion")) {
            String idplaya = request.getParameter("idplaya");
            q=em.createQuery("select p.puntos, count(p.puntos) from Punto p where p.playa.id="+idplaya+" group by p.puntos order by p.puntos");
            
            List<Object[]> resultList = q.getResultList();
            List<PuntoView> puntuaciones = new ArrayList<>();
            for (Object[] row : resultList) {
                puntuaciones.add(new PuntoView((Short) row[0], (Long)row[1]));
            }
            request.setAttribute("puntuaciones", puntuaciones);
            
            dispatcher = request.getRequestDispatcher("puntuaciones.jsp");
            dispatcher.forward(request, response);
        } else if (op.equals("savePuntuacion")){
            String puntos = request.getParameter("puntos");
            playa = (Playa) session.getAttribute("playa");
            usuario = (Usuario) session.getAttribute("usuario");
            
            Punto punto = new Punto(1);
            punto.setPuntos(Short.valueOf(puntos));
            punto.setPlaya(playa);
            punto.setUsuario(usuario);
            EntityTransaction t= em.getTransaction();
            t.begin();
            em.persist(punto);
            t.commit();
            playa = em.find(Playa.class, playa.getId());
            session.setAttribute("playa", playa);
            session.setAttribute("msg", "Anotado "+puntos+" puntos a "+playa.getNombre());
            
            dispatcher = request.getRequestDispatcher("home.jsp");
            dispatcher.forward(request, response);
        }

    }

    /**
     * @see HttpServlet#doPost(HttpServletRequest request, HttpServletResponse
     * response)
     */
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // TODO Auto-generated method stub
        doGet(request, response);
    }

}
