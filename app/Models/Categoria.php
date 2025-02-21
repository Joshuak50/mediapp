<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Categoria extends Model
{
    use HasFactory;
    protected $table = 'categorias';


       // Relación con el modelo User
       public function user()
       {
           return $this->belongsTo(User::class, 'user_id');
       }

}
