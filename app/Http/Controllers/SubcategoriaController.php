<?php

namespace App\Http\Controllers;

use App\Models\Subcategoria;
use Illuminate\Http\Request;

class SubcategoriaController extends Controller
{
    public function index(Request $req){
        if($req->id){
            $subcategoria = Subcategoria::find($req->id);
        }
        else{
            $subcategoria = new Subcategoria();
        }
        return view('subcategoria',compact('subcategoria'));
}
public function getAPI(Request $req){
    $subcategoria = Subcategoria::find($req->id);
    return response()->json($subcategoria);
}

public function listAPI(Request $request) {
    // Obtener los parámetros de la URL
    $userId = $request->query('user_id'); // ID del usuario
    $categoriaId = $request->query('categoria_id'); // ID de la categoría

    // Verificar que ambos parámetros estén presentes
    if (!$userId || !$categoriaId) {
        return response()->json([
            'message' => 'Faltan parámetros requeridos (user_id o categoria_id)',
        ], 400); // Respuesta de error con código 400
    }

    // Filtrar las subcategorías por usuario y categoría
    $subcategorias = Subcategoria::where('id_usuario', $userId)
                                 ->where('id_c', $categoriaId)
                                 ->get();

    // Retornar las subcategorías en formato JSON
    return response()->json([
        'message' => 'Subcategorías obtenidas correctamente',
        'data' => $subcategorias,
    ], 200);
}

public function saveAPI(Request $req)
{
    // Si estás utilizando autenticación, obtén el usuario autenticado
    $idUsuario = $req->user() ? $req->user()->id : $req->id_usuario;

    // Verifica si id_usuario fue obtenido correctamente
    if (!$idUsuario) {
        return response()->json(['error' => 'El campo id_usuario es obligatorio.'], 400);
    }

    // Determina si es actualización o creación
    if ($req->id != 0) {
        $subcategoria = Subcategoria::find($req->id);
        if (!$subcategoria) {
            return response()->json(['error' => 'Subcategoría no encontrada.'], 404);
        }
    } else {
        $subcategoria = new Subcategoria();
    }

    // Validar los datos recibidos
    $validatedData = $req->validate([
        'id_c' => 'required|exists:categorias,id',
        'nombre' => 'required|string|max:255',
        'monto' => 'required|numeric', // Validación para monto
        'fecha' => 'required|date', // Validación para fecha
    ]);

    // Asigna los valores
    $subcategoria->id_c = $validatedData['id_c'];
    $subcategoria->nombre = $validatedData['nombre'];
    $subcategoria->monto = $validatedData['monto']; // Asignar monto
    $subcategoria->fecha = $validatedData['fecha']; // Asignar fecha
    $subcategoria->id_usuario = $idUsuario;  // Asignar id_usuario

    // Guarda la subcategoría
    $subcategoria->save();

    return response()->json(['message' => 'Subcategoría guardada correctamente.'], 200);
}

public function getTotalMontoAPI(Request $request) {
    // Obtener los parámetros de la URL
    $userId = $request->query('user_id'); // ID del usuario
    $categoriaId = $request->query('categoria_id'); // ID de la categoría

    // Verificar que ambos parámetros estén presentes
    if (!$userId || !$categoriaId) {
        return response()->json([
            'message' => 'Faltan parámetros requeridos (user_id o categoria_id)',
        ], 400); // Respuesta de error con código 400
    }

    // Calcular la suma total del monto filtrado por usuario y categoría
    $totalMonto = Subcategoria::where('id_usuario', $userId)
                              ->where('id_c', $categoriaId)
                              ->sum('monto');

    // Retornar la suma total en formato JSON
    return response()->json([
        'message' => 'Suma total del monto obtenida correctamente',
        'data' => [
            'user_id' => $userId,
            'categoria_id' => $categoriaId,
            'total_monto' => $totalMonto,
        ],
    ], 200);
}


public function updateAPI(Request $req, $id) {
    // Validar los datos de entrada
    $validatedData = $req->validate([
        'id_c' => 'required|integer|exists:categorias,id',
        'nombre' => 'required|string|max:255',
        'monto' => 'required|numeric', // Validación para el campo monto
        'fecha' => 'required|date',    // Validación para el campo fecha
    ]);

    // Encontrar o crear la subcategoría
    $subcategoria = Subcategoria::find($id);
    if (!$subcategoria) {
        return response()->json(['error' => 'Subcategoría no encontrada.'], 404);
    }

    // Asignar los valores al modelo
    $subcategoria->id_c = $validatedData['id_c'];
    $subcategoria->nombre = $validatedData['nombre'];
    $subcategoria->monto = $validatedData['monto'];
    $subcategoria->fecha = $validatedData['fecha'];

    // Guardar los cambios
    $subcategoria->save();

    return response()->json(['message' => 'Subcategoría actualizada correctamente.'], 200);
}


public function deleteAPI(Request $req, $id){
    $subcategoria = Subcategoria::find($req->id);
    $subcategoria->delete();
    return "ok";

}
}
