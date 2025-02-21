<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class LoginController extends Controller
{
    public function login(Request $request)
    {
        // Validar los datos de entrada
        $request->validate([
            'email' => 'required|email',
            'password' => 'required',
        ]);

        // Intentar autenticar al usuario
        if (Auth::attempt(['email' => $request->email, 'password' => $request->password])) {
            $user = Auth::user();

            // Crear el token de acceso
            $token = $user->createToken('app')->plainTextToken;

            // Responder con éxito
            return response()->json([
                'acceso' => 'ok',
                'error' => '',
                'token' => $token,
                'idUsuario' => $user->id,
                'nombreUsuario' => $user->name,
            ], 200);  // Código HTTP 200: OK
        } else {
            // Si no se puede autenticar, devolver error
            return response()->json([
                'acceso' => '',
                'token' => '',
                'error' => 'No existe usuario o contraseña',
                'idUsuario' => 0,
                'nombreUsuario' => '',
            ], 401);  // Código HTTP 401: Unauthorized
        }
    }
}
