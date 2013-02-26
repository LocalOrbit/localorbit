<div class="wrap">
    <div class="icon32" id="icon-tools"><br></div>
    <h2>WPZOOM Framework Update</h2>
     
    <div>
        <?php
        $isUpdated = false;
        
        $remoteVersion = WPZOOM_Framework_Updater::get_remote_version();
        $localVersion = WPZOOM_Framework_Updater::get_local_version();
        
        if (preg_match('/[0-9]*\.?[0-9]+/', $remoteVersion)) {
        
            if (version_compare($localVersion, $remoteVersion) < 0) {
                $isUpdated = true;
            }
        
        } else {
            echo '<p>' . $remoteVersion . '</p>';
        }
        ?>
        
        <?php if ($isUpdated) : ?>
            <form method="post" id="wpzoom-update">
                <h3>A new version of WPZOOM Framework is available.</h3>
                <p>This updater will download and extract the latest WPZOOM Framework files to your current theme's functions folder. </p>
                <p>Only the WPZOOM Framework files will be updated with this functionality, so we recommend backing up your theme or modified files before updating.</p>
                <p>&rarr; <strong>Your version:</strong> <?php echo $localVersion; ?></p>
                <p>&rarr; <strong>Remote version:</strong> <?php echo $remoteVersion; ?></p>
                <input type="hidden" name="wpzoom-update-do" value="update" />
                <input type="submit" class="button" value="Update WPZOOM Framework" />
            </form>
            <br><br>
            <?php if (method_exists('WPZOOM_Framework_Updater', 'get_changelog')) : ?>
            <h3>Changelog</h3>
            <div style="height: 200px; max-width: 810px; overflow: scroll; overflow-x: hidden; overflow-y: scroll; border: 1px solid #ccc; border-radius:3px; padding: 0 10px; background: #F8F8F8; font-size: 11px;">
                <?php
                $start = false;
                $changelog = WPZOOM_Framework_Updater::get_changelog();
                $changelog = explode("\n", $changelog);
                foreach ($changelog as $line) {
                    if (preg_match("/v ((?:\d+(?!\.\*)\.)+)(\d+)?(\.\*)?/i", $line)) {
                        $start = true;
                        echo '<h4>' . $line . '</h4>';
                    } elseif($start && trim($line)) {
                        echo '<pre>' . $line . '</pre>';
                    }
                }
                ?>
            </div>
            <?php endif; ?>
        <?php else : ?>
            <p>&rarr; <strong>You are using latest framework version:</strong> <?php echo $localVersion; ?></p>
            <?php option::delete('framework_status'); ?>
        <?php endif; ?>
    </div>
</div><!-- end .wrap -->
