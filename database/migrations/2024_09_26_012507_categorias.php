<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::create(table: 'categorias', callback: function(Blueprint $table):void{
            $table->id();
            $table->string('nombre');
            $table->string('descripcion');
            $table->date('fecha');
            $table->time('hora');
            $table->string('dosis');
            $table->integer('frecuencia');
            $table->string('frecuenciaDias');
            $table->unsignedBigInteger('id_usuario');
            $table->timestamps();

            $table->foreign('id_usuario')->references('id')->on('users');
            
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('categorias');
    }
};
