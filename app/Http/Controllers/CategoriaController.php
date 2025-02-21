<?php

namespace App\Http\Controllers;

use App\Models\Categoria;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class CategoriaController extends Controller
{
    public function index(Request $req){
        if($req->id){
            $categoria = Categoria::find($req->id);
        }
        else{
            $categoria = new Categoria();
        }
        return view('categoria',compact('categoria'));
}
public function getAPI(Request $req){
    $categoria = Categoria::find($req->id);
    return response()->json($categoria);
}

public function listAPI(Request $request) {
    // Obtener el idUsuario del parámetro de la URL
    $userId = $request->query('user_id');  // Asegúrate de que el parámetro de la URL se llame 'user_id'

    // Filtrar las categorías asociadas al usuario con ese id
    $categorias = Categoria::where('id_usuario', $userId)->get();  // Cambia 'user_id' por 'id_usuario'

    return response()->json([
        'message' => 'Categorías obtenidas correctamente',
        'data' => $categorias,
    ], 200);
}

public function saveAPI(Request $req){
    if($req->id !=0){
        $categoria = Categoria::find($req->id);
    }
    else{
        $categoria = new Categoria();
    }
    
    $categoria -> nombre = $req->Nombre;
    $categoria -> descripcion = $req->Descripcion;
    $categoria -> fecha = $req->Fecha;
    $categoria -> hora = $req->Hora;
    $categoria -> dosis = $req->Dosis;
    $categoria -> frecuencia = $req->Frecuencia;
    $categoria->frecuenciaDias = $req->FrecuenciaDias;
    $categoria -> id_usuario = $req->id_usuario;
    $categoria->save();  
    return "ok";

}
public function updateAPI(Request $req, $id){
    if($req->id !=0){
        $categoria = Categoria::find($req->id);
    }
    else{
        $categoria = new Categoria();
    }
    $categoria -> id = $req->id;
    $categoria -> nombre = $req->nombre;
    $categoria -> descripcion = $req->descripcion;
    $categoria -> fecha = $req->fecha;
    $categoria -> hora = $req->hora;
    $categoria -> dosis = $req->dosis;
    $categoria -> frecuencia = $req->frecuencia;
    $categoria -> frecuenciaDias = $req->frecuenciaDias;
    $categoria -> id_usuario = $req->id_usuario;
    $categoria->save();  
    return "ok";

}
public function deleteAPI(Request $req, $id){
    $categoria = Categoria::find($req->id);
    $categoria->delete();
    return "ok";

}
}
