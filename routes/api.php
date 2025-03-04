<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\LoginController as ControllersLoginController;
use App\Http\Controllers\CategoriaController;
use App\Http\Controllers\SubcategoriaController;
use App\Http\Controllers\UsuarioController;
use App\Models\Categoria;
use App\Models\Subcategoria;
Use App\Models\Usuario;

Route::get('/user', function (Request $request) {
    return $request->user();
})->middleware('auth:sanctum');

Route::post('login',[ControllersLoginController::class,'login']);

Route::get('categorias',[CategoriaController::class,'listAPI']);
Route::post('categoria',[CategoriaController::class,'getAPI']);
Route::post('categoria/guardar',[CategoriaController::class,'saveAPI']);
//Route::post('categoria/actu',[CategoriaController::class,'updateAPI']);
Route::put('categoria/{id}/actu',[CategoriaController::class,'updateAPI']);
Route::delete('categoria/{id}/borrar',[CategoriaController::class,'deleteAPI']);

Route::get('subcategorias',[SubcategoriaController::class,'listAPI']);
Route::post('subcategoria',[SubcategoriaController::class,'getAPI']);
Route::post('subcategoria/guardar',[SubcategoriaController::class,'saveAPI']);
Route::put('subcategoria/{id}/actu',[SubcategoriaController::class,'updateAPI']);
Route::delete('subcategoria/{id}/borrar',[SubcategoriaController::class,'deleteAPI']);

Route::post('usuarios/guardar', [UsuarioController::class, 'saveApi']);
Route::get('/usuario/{id}', [UsuarioController::class, 'getUsuario']);
Route::get('subcategoria/monto',[SubcategoriaController::class, 'getTotalMontoAPI']);