<?php
namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Log;
use App\Models\User;
use App\Models\Usuario;

class UsuarioController extends Controller
{
    public function saveAPI(Request $req)
{
    // Validaciones
    $req->validate([
        'nombre' => 'required|string|max:255',
        'correo' => 'required|email|unique:users,email',
        'contrasena' => 'required|min:8',
        'imagen' => 'nullable|image|max:2048',
    ]);

    try {
        // Manejo de la imagen
        $pathImagen = null;
        if ($req->hasFile('imagen')) {
            $pathImagen = $req->file('imagen')->store('usuarios', 'public');
        }

        // Crear el User
        $user = new User();
        $user->name = $req->nombre;
        $user->email = $req->correo;
        $user->password = Hash::make($req->contrasena);
        //$user->imagen = $pathImagen;
        $user->save();

        //Crear el usuarios
        $usuario = new Usuario();
        $usuario->nombre_completo = $req->nombre;
        $usuario->correo = $req->correo;
        $usuario->contraseña = Hash::make($req->contrasena);
        $usuario->imagen = $pathImagen;
        $usuario->save();

        return response()->json([
            'message' => 'Usuario guardado correctamente',
            'data' => [
                'nombre' => $user->name,
                'correo' => $user->email,
                //'imagen' => $pathImagen,
            ]
        ], 200);
    } catch (\Exception $e) {
        Log::error('Error al guardar el usuario: ' . $e->getMessage());
        return response()->json(['message' => 'Error al guardar el usuario'], 500);
    }
}

public function getUsuario($id)
{
    try {
        $usuario = Usuario::where('id', $id)->first();

        if (!$usuario) {
            return response()->json(['message' => 'Usuario no encontrado'], 404);
        }

        return response()->json([
            'nombre' => $usuario->nombre_completo,
            'imagen' => $usuario->imagen ? asset('storage/' . $usuario->imagen) : null,
        ], 200);
    } catch (\Exception $e) {
        Log::error('Error al obtener el usuario: ' . $e->getMessage());
        return response()->json(['message' => 'Error al obtener el usuario'], 500);
    }
}

}
