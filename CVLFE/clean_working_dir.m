function clean_working_dir( working_dir, backup_dir )

    movefile( fullfile( working_dir, '*' ), backup_dir );

end