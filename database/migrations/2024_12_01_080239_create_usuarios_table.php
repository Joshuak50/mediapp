<?php
use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

class CreateUsuariosTable extends Migration
{
    public function up()
    {
        Schema::create('usuarios', function (Blueprint $table) {
            $table->id(); // ID auto incremental
            $table->string('imagen')->nullable(); // Imagen del usuario (puede ser nula)
            $table->string('nombre_completo'); // Nombre completo del usuario
            $table->string('correo')->unique(); // Correo del usuario, único
            $table->string('contraseña'); // Contraseña del usuario
            $table->timestamps(); // Tiempos de creación y actualización
        });
    }

    public function down()
    {
        Schema::dropIfExists('usuarios');
    }
}
