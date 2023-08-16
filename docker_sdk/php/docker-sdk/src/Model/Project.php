<?php

/**
 * This file is part of the Spryker Suite.
 * For full license information, please view the LICENSE file that was distributed with this source code.
 */

namespace DockerSDK\Model;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsToMany;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\Relations\HasOne;

class Project extends Model
{
    protected $table = 'projects';

    protected $fillable = [
        'name',
        'path',
        'latest_bootable',
        'status',
        'data',
        'created_at',
        'updated_at',
    ];

    protected $casts = [
        'latest_bootable' => 'boolean',
    ];

    public function sharedServices(): BelongsToMany
    {
        return $this->belongsToMany(
            SharedService::class,
            'shared_services_projects',
            'project_id',
            'shared_service_id'
        )->using(
            SharedServiceProject::class
        )->withPivot(['data']);
    }

    public function projectServiceEndpoints(): HasMany
    {
        return $this->hasMany(ProjectServiceEndpoint::class);
    }

    public function storage(): HasOne
    {
        return $this->hasOne(ProjectStorage::class);
    }
}
