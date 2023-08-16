<?php

/**
 * This file is part of the Spryker Suite.
 * For full license information, please view the LICENSE file that was distributed with this source code.
 */

namespace DockerSDK\Model;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsToMany;

class SharedService extends Model
{
    protected $table = 'shared_services';

    protected $fillable = [
        'name',
        'engine',
        'version',
    ];

    public $timestamps = false;

    public function projects(): BelongsToMany
    {
        return $this->belongsToMany(
            Project::class,
            'shared_services_projects',
            'shared_service_id',
            'project_id',
        )->using(
            SharedServiceProject::class
        )->withPivot(['data']);
    }
}
