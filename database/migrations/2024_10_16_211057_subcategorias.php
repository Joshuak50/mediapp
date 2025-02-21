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
        Schema::create(table: 'subcategorias', callback: function(Blueprint $table):void{
            $table->id();
            $table->unsignedBigInteger(column: 'id_c');
            $table->string('nombre');  
            $table->unsignedBigInteger('id_usuario');
            $table->timestamps();
            $table->float('monto');
            $table->date('fecha');
            $table->foreign('id_c')->references('id')->on('categorias');
            $table->foreign('id_usuario')->references('id')->on('users'); 
            
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('subcategorias');
    }
};
