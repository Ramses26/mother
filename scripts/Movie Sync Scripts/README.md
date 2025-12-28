# Project Mother - Automated Sync & Deletion Scripts

**Last Updated:** December 28, 2024  
**Status:** Ready for overnight execution

## 🎯 Quick Start (Recommended)

For unattended overnight execution:

```bash
cd /opt/mother/scripts  # Or wherever you git pulled these scripts
bash preflight_checks.sh  # Verify system is ready
screen -S project-mother
bash project_mother_master.sh  # Run the full automated process
# Ctrl+A, D to detach
```

Check progress later:
```bash
screen -r project-mother  # Reattach
tail -f /opt/mother/logs/project_mother_*.log  # Watch logs
```

## 📂 Scripts in This Folder

### Main Scripts

1. **preflight_checks.sh** - Run this FIRST
   - Verifies all mounts are active
   - Checks disk space (need 2.3TB free on each)
   - Tests write permissions
   - Estimates completion time
   - Exit code 0 = ready to proceed

2. **project_mother_master.sh** - The orchestration script
   - Runs entire process unattended
   - Sync-then-delete strategy (files never missing)
   - Resume capability if interrupted
   - Full logging to /opt/mother/logs/
   - Estimated time: 45-52 hours

### Helper Scripts (Called by Master)

3. **DELETE_Synology_Movies.sh** - Deletes Chris's lower quality movies
4. **DELETE_Synology_4K.sh** - Deletes Chris's lower quality 4K movies
5. **DELETE_Unraid_Movies.sh** - Deletes Ali's lower quality movies
6. **DELETE_Unraid_4K.sh** - Deletes Ali's lower quality 4K movies

## 🔄 What the Master Script Does

**SYNC-THEN-DELETE STRATEGY** (Files never missing!)

### Phase 1: Sync Movies
1. Ali → Chris: Copy Ali's better/unique movies to Synology
2. Chris → Ali: Copy Chris's better/unique movies to Unraid

### Phase 2: Delete Movies (Now Duplicates)
3. Delete Chris's 1,534 lower quality movies → `/mnt/synology/rs-4kmedia/deleted/movies/`
4. Delete Ali's 513 lower quality movies → `/mnt/unraid/media/Deleted/Movies/`

### Phase 3: Sync 4K Movies
5. Ali → Chris: Copy Ali's better/unique 4K to Synology
6. Chris → Ali: Copy Chris's better/unique 4K to Unraid

### Phase 4: Delete 4K (Now Duplicates)
7. Delete Chris's 94 lower quality 4K → `/mnt/synology/rs-4kmedia/deleted/4kmovies/`
8. Delete Ali's 6 lower quality 4K → `/mnt/unraid/media/Deleted/4kMovies/`

## ✅ Why Sync-Then-Delete is Safe

- **Better version arrives BEFORE worse version leaves**
- If sync fails, nothing is deleted (rollback)
- Files are NEVER missing during the process
- Can verify each phase completed before next phase starts
- Resume capability if process interrupted

## 📊 Expected Results

**Before Execution:**
- Ali Movies: 5,993 files
- Chris Movies: 7,226 files
- Ali 4K: 229 files
- Chris 4K: 162 files

**After Execution:**
- Ali Movies: ~7,776 files (+1,783 from Chris)
- Chris Movies: ~7,942 files (+716 from Ali)
- Ali 4K: ~239 files (+10 from Chris)
- Chris 4K: ~237 files (+75 from Ali)

**Deleted Files:**
- Ali's Deleted folder: 519 files (513 + 6)
- Chris's Deleted folder: 1,628 files (1,534 + 94)

## ⏱️ Time Estimates

At 100 MB/s transfer rate:
- Movies sync: ~35-40 hours (12.5 TB bidirectional)
- 4K sync: ~10-12 hours (3.5 TB bidirectional)
- Deletions: ~30 minutes total
- **Total: ~45-52 hours**

Start Friday night → Complete by Monday morning

## 🔒 Safety Features

1. **Pre-flight checks** - Won't start if system not ready
2. **Error handling** - Stops on any failure
3. **Resume capability** - Can continue if interrupted
4. **Full logging** - Every action logged with timestamp
5. **Dry-run mode** - Test without making changes
6. **State tracking** - Knows which phase it's in
7. **Deleted folders** - Files moved, not permanently deleted

## 🚨 Error Recovery

If script fails or is interrupted:

1. Check logs: `/opt/mother/logs/project_mother_*.log`
2. Check state: `/opt/mother/.project_mother_state`
3. Rerun: `bash project_mother_master.sh`
4. Script will ask if you want to resume from last state

## 📋 Manual Execution (Not Recommended)

If you want to run phases separately:

```bash
# Sync only (no deletions)
rsync -avh /mnt/unraid/media/Movies/ /mnt/synology/rs-movies/
rsync -avh /mnt/synology/rs-movies/ /mnt/unraid/media/Movies/

# Delete only (after sync completes)
bash DELETE_Synology_Movies.sh  # Edit EXECUTE=true first
bash DELETE_Unraid_Movies.sh    # Edit EXECUTE=true first
```

## 🔧 Configuration

Edit `project_mother_master.sh` to change:

```bash
DRY_RUN=false    # Set to true for testing
LOG_DIR="/opt/mother/logs"  # Change log location
```

## 📝 Logs

All logs saved to: `/opt/mother/logs/`

Files created:
- `project_mother_YYYYMMDD_HHMMSS.log` - Main log
- `project_mother_YYYYMMDD_HHMMSS.log.rsync_movies_ali_to_chris` - Rsync details
- `project_mother_YYYYMMDD_HHMMSS.log.rsync_movies_chris_to_ali` - Rsync details
- `project_mother_YYYYMMDD_HHMMSS.log.rsync_4k_ali_to_chris` - Rsync details
- `project_mother_YYYYMMDD_HHMMSS.log.rsync_4k_chris_to_ali` - Rsync details

## ✅ Post-Execution Verification

After completion:

```bash
# Check file counts
ls /mnt/synology/rs-movies/ | wc -l          # Should be ~7,942
ls /mnt/unraid/media/Movies/ | wc -l         # Should be ~7,776
ls "/mnt/synology/rs-4kmedia/4kmovies/" | wc -l  # Should be ~237
ls "/mnt/unraid/media/4K Movies/" | wc -l    # Should be ~239

# Check deleted folders
ls /mnt/synology/rs-4kmedia/deleted/movies/ | wc -l  # Should be 1,534
ls /mnt/unraid/media/Deleted/Movies/ | wc -l         # Should be 513
```

## 🎯 Git Workflow

These scripts are in your git repo for version control:

```bash
# Pull latest version
cd /opt/mother
git pull

# Make changes
nano scripts/project_mother_master.sh

# Commit and push
git add scripts/
git commit -m "Update Project Mother scripts"
git push
```

## ⚠️ Important Notes

1. **Run on Mother server** - Not on Unraid or Synology
2. **Requires NFS mounts active** - Check with `mount | grep mnt`
3. **Needs 2.3TB free** on both Unraid and Synology
4. **Uses screen/tmux** - Don't run in regular SSH session (will timeout)
5. **VPN must stay up** - If VPN drops, script will fail
6. **Takes 2+ days** - Plan accordingly

## 🆘 Troubleshooting

**Script won't start:**
- Run `bash preflight_checks.sh`
- Check all mounts: `mount | grep mnt`
- Verify disk space: `df -h | grep mnt`

**Rsync fails:**
- Check VPN: `ping 192.168.1.10`
- Check mounts: `ls /mnt/unraid/media/Movies/`
- Check logs: `tail /opt/mother/logs/*.log`

**Want to cancel:**
- Ctrl+C to stop
- State is saved, can resume later
- Or delete `/opt/mother/.project_mother_state` to start fresh

**Need help:**
- Check logs in `/opt/mother/logs/`
- Review state in `/opt/mother/.project_mother_state`
- Post logs in project discussion

## 📄 License

Project Mother Scripts - Internal Use Only

---

**Ready to execute? Start with `bash preflight_checks.sh`**
