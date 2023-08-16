<?php

/**
 * This file is part of the Spryker Suite.
 * For full license information, please view the LICENSE file that was distributed with this source code.
 */

namespace DockerSDK\Model;

use Illuminate\Database\Eloquent\Relations\Pivot;

class SharedServiceProject extends Pivot
{
    protected $table = 'shared_services_projects';

    protected $fillable = [
        'shared_service_id',
        'project_id',
        'data',
        'endpoints',
        'init_project',
    ];

    public $timestamps = false;

}
